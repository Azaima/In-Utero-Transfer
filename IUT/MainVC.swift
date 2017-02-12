//
//  MainVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 30/01/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import SwiftKeychainWrapper

class MainVC: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var updateStatusButton: UIButton!
    @IBOutlet weak var administrativeToolsButton: UIButton!
    var functionButtons = [UIButton]()
    @IBOutlet weak var cotStatusLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    
    @IBOutlet weak var changeHospitalButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
 
    @IBOutlet weak var selectedRegionLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var geocoder = CLGeocoder()
    
    @IBOutlet weak var regionsTable: UITableView!
    @IBOutlet weak var regionSelectionStack: UIStackView!
    
    
    var myLocation: CLLocation? {
        didSet{
            userLabel.text = "Initiating Application"
            currentLocation = myLocation
            if let userID = KeychainWrapper.standard.string(forKey: USER_UID) {
                
                loggedInUserID = userID
                
                DataService.ds.REF_USERS.child(userID).observe( .value, with: { (user) in
                    
                    let dataObtained = user.value as? [String: Any]
                    country = dataObtained?["country"] as! String
                    loggedInUserRegion = dataObtained?["region"] as! String
                    
                    
                    DataService.ds.REF_REGIONS.child(country).observeSingleEvent(of: .value, with: { (regionsSnap) in
                        
                        if let regionsSnap = regionsSnap.value as? [String: Any] {
                            regions = regionsSnap
                        }
                        self.activityIndicator.startAnimating()
                        self.prepareDataBase {
                            self.activityIndicator.stopAnimating()
                            self.stack.isHidden = false
                            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                            if self.firstStartup {
                                self.firstStartup = false
                            }
                            loggedInUserData = dataObtained

                            
                        }

                    })
                })
            } else {

            
                geocoder.reverseGeocodeLocation(myLocation!, completionHandler: { (locationName, error) in
                    if error == nil {
                        print("\((locationName?[0].country)!)\t \((locationName?[0].addressDictionary?["City"])!)")
                        country = (locationName?[0].country)!
                        
                        DataService.ds.REF_REGIONS.child(country).observeSingleEvent(of: .value, with: { (regionsSnap) in
                            
                            if let regionsSnap = regionsSnap.value as? [String: Any] {
                                regions = regionsSnap
                                
                                if regions[(locationName?[0].addressDictionary?["City"]) as! String]  != nil {
                                    
                                    loggedInUserRegion = (locationName?[0].addressDictionary?["City"]) as! String
                                    networks = regions[(locationName?[0].addressDictionary?["City"]) as! String] as! [String]
                                }   else if regions.count == 1 {
                                    for region in regions {
                                        loggedInUserRegion = region.key
                                        networks = region.value as! [String]
                                    }
                                }   else {
                                    self.regionSelectionStack.isHidden = false
                                }
                                
                                if loggedInUserRegion != "" {
                                    self.startPrepping()
                                }
                            }
                        })
                    }
                })
            }
            
            
        }
    }
    
    func startPrepping() {
        self.activityIndicator.startAnimating()
        self.prepareDataBase {
            self.activityIndicator.stopAnimating()
            self.stack.isHidden = false
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            if self.firstStartup {
                self.firstStartup = false
            }
            
        }
    }
    
    var firstStartup = true
    var loggedInComplete = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainscreen = self
        
        regionsTable.delegate = self
        regionsTable.dataSource = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startMonitoringSignificantLocationChanges()
        locationStatus()
        functionButtons = [feedbackButton,updateStatusButton,administrativeToolsButton, changeHospitalButton]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//        insertNewDatabase()
        
//        _ = KeychainWrapper.standard.removeAllKeys()
        

    }

    
    
    
    func insertNewDatabase() {
        
        DataService.ds.REF_COT_STATUS_ARCHIVE.observeSingleEvent(of: .value, with: { (hospitals) in
            if let hospitalsData = hospitals.value as? [String: Any] {
                
                DataService.ds.REF_COT_STATUS_ARCHIVE.child("United Kingdom").child("London").updateChildValues(hospitalsData)
            }
        })
    }
    
    func locationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            myLocation =  locationManager.location
            
            
        }   else {
            locationManager.requestWhenInUseAuthorization()
            
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus()
    }
    
    func prepareDataBase(complete: @escaping DownloadComplete) {

        self.userLabel.text = "\(country) - \(loggedInUserRegion)"
        DataService.ds.REF_HOSPITALS_BY_REGION.child(country).child(loggedInUserRegion).queryOrderedByKey().observe(.value, with: { (snapshot) in
            hospitalsArray = [NO_HOSPITAL, EBS_Struct]

            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                
                for snap in snapshot {
                    let hospital = HospitalStruct(hospitalSnap: snap)
                    if hospital.name == loggedHospitalName {
                        loggedInUserHospital = hospital
                    }
                    hospitalsArray.append(hospital)
                }
                
                DataService.ds.REF_REGIONS.child(country).child(loggedInUserRegion).observe(.value, with: { (networksSnapshot) in
                    
                    if let networksSnap = networksSnapshot.value as? [String] {
                        networks = networksSnap
                        
                        sortHospitalsToNetworksAndLevels()
                    }
                })

                
            }
            
            
            complete()

        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignInVC" {
            let destination = segue.destination as! SignInVC
            destination.register = sender as! Bool
            destination.mainVC = self
        }
        if segue.identifier == "databaseForStatusUpdate"{
            
            let destination = segue.destination as! HospitalsDatabaseVC
            destination.updatingCotStatus = true
        }
        
        if segue.identifier == "detailsForStatusUpdate" {
            let destination = segue.destination as! HospitalDetailsVC
            destination.updatingCotStatus = true
            destination.hospital = loggedInUserHospital
        }
        
    }

    @IBAction func signinPressed(_ sender: UIButton) {

        let register = sender.tag == 1
        performSegue(withIdentifier: "SignInVC", sender: register)
    }

    
    func toggleSignInButton(signedIn: Bool, userData: [String:Any]?) {
        
        signInButton.isHidden = signedIn
        registerButton.isHidden = signedIn
        signOutButton.isHidden = !signedIn
        editProfileButton.isHidden = !signedIn
        loggedIn = signedIn
        
        if signedIn && userData != nil {
            
            loggedHospitalName = (userData?["hospital"] as! String)
            loggedInUserHospital = hospitalsArray[hospitalsArray.index(where: { (HospitalStruct) -> Bool in
                return HospitalStruct.name == loggedHospitalName
            })!]
            userLabel.text = "\(country) - \(loggedInUserRegion)\nCurrently Logged in as - \((userData?["firstName"])!) \((userData?["surname"])!)"
            if loggedHospitalName != "(None)" {
                userLabel.text = "\((self.userLabel.text)!)\nUser is linked to \(loggedHospitalName!)"
            }
            feedbackButton.isHidden = false
            if userData?["hospital"] as! String != "(None)" && userData?["statusRights"] as? String == "true" || userData?["superUser"] as? String == "true" || userData?["ultimateUser"] as? String == "true" {
                updateStatusButton.isHidden = false
                
                if loggedHospitalName != nil && loggedHospitalName != "(None)" && loggedHospitalName != "E B S" {
                    cotStatusLabel.isHidden = false
                    let hospital = hospitalsArray[hospitalsArray.index(where: { (HospitalStruct) -> Bool in
                        return HospitalStruct.name == loggedHospitalName
                    })!]
                    if hospital.cotsAvailable != nil {
                        cotStatusLabel.text = "You currently have \((loggedInUserHospital?.cotsAvailable)!) cots available\nLast updated \((loggedInUserHospital?.cotsUpdate)!)"
                    }   else {
                        cotStatusLabel.text = "Your cot status has never been updated"
                    }
                    
                }
    
            }
            
            if loggedHospitalName == "(None)" || loggedHospitalName == "E B S" {
                cotStatusLabel.isHidden = true
            }
            
            if userData?["adminRights"] as? String == "true" || userData?["superUser"] as? String == "true" || userData?["ultimateUser"] as? String == "true"{
                administrativeToolsButton.isHidden = false
            }
            
            if userData?["ultimateUser"] as? String == "true" {
                changeHospitalButton.isHidden = false
            }

        }   else {
            userLabel.text = "\(country) - \(loggedInUserRegion)\nCurrently Logged in as - Guest User"
            for button in functionButtons {
                button.isHidden = true
            }
            cotStatusLabel.isHidden = true
        }
    }
    
    @IBAction func signOutPressed(_ sender: UIButton) {
        KeychainWrapper.standard.removeObject(forKey: USER_UID)
        loggedHospitalName = nil
        try! FIRAuth.auth()?.signOut()
        print("Signed Out Successfully")
        toggleSignInButton(signedIn: false, userData: nil)
        
    }
    
    @IBAction func feedbackPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "FeedbackVC", sender: nil)
    }
    @IBAction func adminToolsPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "AdministrativeToolsVC", sender: nil)
    }
    
    @IBAction func arrangeTransferPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "SourceOfTransferVC", sender: nil)
    }
    
    
    @IBAction func statusUpdatePressed(_ sender: Any) {
        if loggedInUserHospital?.name == "E B S" {
            performSegue(withIdentifier: "databaseForStatusUpdate", sender: nil)
        }   else {
            performSegue(withIdentifier: "detailsForStatusUpdate", sender: nil)
        }
    }
    
    //MARK: TableView Delegate and Ultimate user functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hospitalCellmainVC")
        cell?.textLabel?.text = regions.sorted(by: { (region1: (key: String, value: Any), region2: (key: String, value: Any)) -> Bool in
            return region1.key < region2.key
        })[indexPath.row].key
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        regionSelectionStack.isHidden = true
        loggedInUserRegion = regions.sorted(by: { (region1: (key: String, value: Any), region2: (key: String, value: Any)) -> Bool in
            return region1.key < region2.key
        })[indexPath.row].key
        selectedRegionLabel . text = loggedInUserRegion
        
        networks = regions.sorted(by: { (region1: (key: String, value: Any), region2: (key: String, value: Any)) -> Bool in
            return region1.key < region2.key
        })[indexPath.row].value as! [String]

        startPrepping()
    }
    
    @IBAction func regionsLabelPressed(_ sender: UITapGestureRecognizer) {
        regionsTable.isHidden = !regionsTable.isHidden
    }
    
    
//    @IBAction func changeHospitalPressed(_ sender: Any) {
//        if hospitalTable.isHidden {
//            hospitalTable.isHidden = false
//            hospitalTable.selectRow(at: IndexPath(row: hospitalsArray.index(where: { (HospitalStruct) -> Bool in
//                return HospitalStruct.name == loggedHospitalName
//            })!, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.none)
//            
//            hospitalTable.scrollToRow(at: IndexPath (row: hospitalsArray.index(where: { (HospitalStruct) -> Bool in
//                return HospitalStruct.name == loggedHospitalName
//            })!, section: 0), at: UITableViewScrollPosition.none, animated: true)
//            
//            changeHospitalButton.setTitle("Confirm", for: .normal)
//            changeHospitalButton.backgroundColor = UIColor(red: 81/255, green: 164/255, blue: 1, alpha: 1)
//            changeHospitalButton.setTitleColor(UIColor.white, for: .normal)
//
//        }   else {
//            hospitalTable.isHidden = true
//            if hospitalTable.indexPathForSelectedRow != nil {
//                loggedInUserHospital = hospitalsArray[(hospitalTable.indexPathForSelectedRow?.row)!]
//            }
//            loggedHospitalName = loggedInUserHospital?.name
//            loggedInUserData?["hospital"] = loggedHospitalName!
//            changeHospitalButton.setTitle("Change Hospital", for: .normal)
//            changeHospitalButton.backgroundColor = .white
//            changeHospitalButton.setTitleColor(UIColor.darkGray, for: .normal)
//            toggleSignInButton(signedIn: true, userData: loggedInUserData)
//        }
//    }
    
}

