//
//  HomePageVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 07/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import MapKit
import CoreLocation

class HomePageVC: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate {
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var aboutTapped: UITapGestureRecognizer!
    @IBOutlet var contactTapped: UITapGestureRecognizer!
    
    @IBOutlet weak var hospMapView: MKMapView!
    @IBOutlet weak var editProfile: UILabel!
    
    @IBOutlet weak var greetingView: UIView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var loginRegisterLabel: UILabel!
    
    let alertMessage = UIAlertController(title: nil, message: "", preferredStyle: UIAlertControllerStyle.alert)
    var controller: NSFetchedResultsController<SessionData>!
    var sessionDataList = [SessionData]()
    
    @IBOutlet weak var arrangeTansferBtn: UIButton!
    @IBOutlet weak var updateCotBtn: UIButton!
    @IBOutlet weak var hospitalAdminBtn: UIButton!
    @IBOutlet weak var superUserBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertMessage.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        homePage = self
        
        
        
        hospMapView.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 51.500679, longitude: -0.108168), 15000, 15000), animated: true)
        
        fetchSessionData()
        setupDataBase()
        
        hospMapView.delegate = self
    }
    
    @IBAction func displayMessagePressed(_ sender: Any) {
        performSegue(withIdentifier: "displayMessage", sender: sender)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        if loginRegisterLabel.text == "Sign Out" {
            
            
            do {
                try FIRAuth.auth()?.signOut()
                for session in sessionDataList {
                    
                    context.delete(session)
                }
                
                context.delete(sessionData!)
                ad.saveContext()
                
                userData = [:]
                setGreeting(visible: false)
            }   catch {
                alertMessage.message = "An error occured while signing out"
                present(alertMessage, animated: true, completion: nil)
            }
        }   else {
            performSegue(withIdentifier: "loginRegisterSegue", sender: sender)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender is UITapGestureRecognizer {
            if (sender as? UITapGestureRecognizer == aboutTapped || sender as? UITapGestureRecognizer == contactTapped) {
                
                let messageForDisplay = sender as? UITapGestureRecognizer == aboutTapped ? "aboutMessage" : "contactMessage"
                let pageTitle = messageForDisplay == "aboutMessage" ? "About CotFinder" : "Contact Us"
                
                let destination = segue.destination as! AboutMessageVC
                
                destination.messageForDisplay = messageForDisplay
                destination.pageTitle = pageTitle
            }
        }   else if sender is InfoButton {
            let destination = segue.destination as! HospitalCotDetailsVC
            destination.key = (sender as! InfoButton).key!
        }   else if segue.identifier == "updateCotsVC" {
            let destination = segue.destination as! UpdateCotsVC
            destination.hospital = userData["hospitalStructure"] as? HospitalStructure
        }
        
    }
    
    func fetchSessionData(){
        let fetchRequest: NSFetchRequest<SessionData> = SessionData.fetchRequest()
        let dateSort = NSSortDescriptor(key: "lastLogin", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        do {

            try controller.performFetch()
            if let sessionInfo = controller.fetchedObjects?.last {
                sessionDataList = controller.fetchedObjects!
                sessionData = sessionInfo
                FIRAuth.auth()?.signIn(withEmail: (sessionData?.email)!, password: (sessionData?.password)!, completion: { (user, error) in
                    if error != nil {
                        self.alertMessage.message = "An error occured while trying to log in.\n\((error?.localizedDescription)!)"
                        self.present(self.alertMessage, animated: true, completion: nil)
                    }   else {
                        self.getUserData()
                    }
                })
            }
            
        }   catch {
        
        }
    }
    
    func getUserData(){
        
        DB_BASE.child("users").child((sessionData?.uid!)!).observe(FIRDataEventType.value, with: { (snapshot) in
            if let userSnap = snapshot.value as? [String: Any]{
                userData = userSnap
                if let index = hospitals.index(where: { (hospital) -> Bool in
                    return hospital.key == userData["hospitalKey"] as! String
                }){
                    let hospital = hospitals[index]
                    hospital.markView.image = #imageLiteral(resourceName: "Home")
                    self.hospMapView.setCenter(hospital.location, animated: true)
                    userData["hospitalStructure"] = hospital
                    
                    COTFINDER2_REF.child("usersByHospital").child(hospital.key).child(sessionData!.uid!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                            
                        let userRights = UserAdminRecord(userFileSnap: snapshot)
                        self.arrangeTansferBtn.isHidden = false
                        
                        if (userRights.updateCots != nil && userRights.updateCots == true) || (userRights.superUser != nil && userRights.superUser == true){
                            self.updateCotBtn.isHidden = false
                        }   else {
                            self.updateCotBtn.isHidden = true
                        }
                        
                        if (userRights.admin != nil && userRights.admin == true) || (userRights.superUser != nil && userRights.superUser == true){
                            self.hospitalAdminBtn.isHidden = false
                        }   else {
                            self.hospitalAdminBtn.isHidden = true
                        }
                        
                        if (userRights.superUser != nil && userRights.superUser == true){
                            self.superUserBtn.isHidden = false
                        }   else {
                            self.superUserBtn.isHidden = true
                        }
                        
                    })
                }
                self.setGreeting(visible: true)
            }
        })
    }
    
    func setGreeting(visible: Bool){
        greetingView.isHidden = !visible
        
        if visible {
            markers[userData["hospitalKey"] as! String]?.image = #imageLiteral(resourceName: "Home")
            if let location =  markers[userData["hospitalKey"] as! String]?.annotation?.coordinate {
                hospMapView.setCenter(location, animated: true)
            }
            greetingLabel.text = "Good \(getGreeting()) \(userData["firstName"]!)."
            switch getGreeting() {
            case "morning":
                greetingView.backgroundColor = UIColor(red: 7 / 255, green: 126 / 255, blue: 236 / 255, alpha: 0.5)
            case "afternoon":
                greetingView.backgroundColor = UIColor(red: 226 / 255, green: 187 / 255, blue: 63 / 255, alpha: 0.5)
            default:
                greetingView.backgroundColor = UIColor(red: 166 / 255, green: 81 / 255, blue: 208 / 255, alpha: 0.5)
            }
            editProfile.isHidden = false
            loginRegisterLabel.text = "Sign Out"
            loginRegisterLabel.backgroundColor = UIColor(red: 249 / 255, green: 19 / 255, blue: 28 / 255, alpha: 1)
        }   else {
            editProfile.isHidden = true
            loginRegisterLabel.text = "Log In/Register"
            loginRegisterLabel.backgroundColor = UIColor(red: 7 / 255, green: 126 / 255, blue: 236 / 255, alpha: 1)
        }
    }
    
    
    //    MARK: Setup App Views
    func setupDataBase(){
        startIndicator()
        COTFINDER2_REF.child("hospitals").observeSingleEvent(of: FIRDataEventType.value, with: { (allHospitalsSnap) in
            if let hospitalsSnap = allHospitalsSnap.children.allObjects as? [FIRDataSnapshot]{
                for hospitalSnap in hospitalsSnap {
                    let hospital = HospitalStructure(hospitalSnap: hospitalSnap)
                    hospitals.append(hospital)
                    self.hospMapView.addAnnotation(hospital.mark!)
                }
                self.stopIndicator()
            }
        }) {(error) in
            self.alertMessage.message = "An error occured while attempting to download the hospital Database.\nError: \(error.localizedDescription)"
            self.present(self.alertMessage, animated: true, completion: nil)
        }
        
        
        COTFINDER2_REF.child("cotStatus").observe(.value, with: { (snapshot) in
            if let cotSnap = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for  snap in cotSnap {
                    cotStatusRecords[snap.key] = CotStatusRecord(recordSnap: snap)
                    if let index = hospitals.index(where: { (hospital) -> Bool in
                        return hospital.key == snap.key
                    }){
                        let hospital = hospitals[index]
                        hospital.markView.image = self.setImageForAnnotation(for: snap.key, level: hospital.level)
                        hospital.mark?.subtitle = getCotStatus(for: snap.key, outcome: "brief")
                        
                    }
                }
            }
        }) {(error) in
            self.alertMessage.message = "An error occured while attempting to download cot status Data.\nError: \(error.localizedDescription)"
            self.present(self.alertMessage, animated: true, completion: nil)
        }
    }
    


//    Map view functions


    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let marker = annotation as! HospitalMarker
        let annoview = MKAnnotationView(annotation: annotation, reuseIdentifier: marker.key)

        if let index = hospitals.index(where: { (hospital: HospitalStructure) -> Bool in
            return hospital.key == marker.key
        }) {
            let hospital = hospitals[index]
            hospital.markView = annoview
        }
        
        annoview.canShowCallout = true
        if marker.key != "ebs-uk" {
            let button = InfoButton()
            button.key = marker.key
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.setImage(UIImage(named: "infoBtn"), for: .normal)
            annoview.rightCalloutAccessoryView = button
            button.addTarget(InfoButton?.self, action: #selector(infoButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        }

        annoview.image = setImageForAnnotation(for: marker.key, level: marker.level)
        
        return annoview

    }
    
    func setImageForAnnotation(for key: String, level: Int) -> UIImage{

        var update = 2
        if let cotUpdateRecord = cotStatusRecords[key]{

            let time = Int(cotUpdateRecord.lastUpdate.time.timeIntervalSinceNow)

            if time > -21600 {
                update = 0
            }   else if time > -43200 {
                update = 1
            }

        }
        
        var image: UIImage
        
        switch level {
        case 0:
            image = #imageLiteral(resourceName: "LAS_Logo1-icon")
        default:
            image = UIImage(named: "level-\(level)-\(update)")!
        }
        

        if !userData.isEmpty {
            if userData["hospitalKey"] as! String == key {
                image = #imageLiteral(resourceName: "Home")
            }
        }
        
        return image
    }
    
    @IBAction func infoButtonPressed(_ sender: InfoButton){
        performSegue(withIdentifier: "hospitalDetailsVC", sender: sender)
    }
    
    
    func startIndicator(){
        indicatorView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func stopIndicator(){
        indicatorView.isHidden = true
        activityIndicator.stopAnimating()
    }
    
}
