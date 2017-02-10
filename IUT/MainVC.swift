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
    
    
    @IBOutlet weak var hospitalTable: UITableView!
    
    var locationManager = CLLocationManager()
    var myLocation: CLLocation? {
        didSet{
            currentLocation = myLocation
            self.activityIndicator.startAnimating()
            self.prepareDataBase {
                self.activityIndicator.stopAnimating()
                self.stack.isHidden = false
                self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                if self.firstStartup {
                    self.firstStartup = false
                    if let userID = KeychainWrapper.standard.string(forKey: USER_UID) {
                        
                        loggedInUserID = userID
                        
                        DataService.ds.REF_USERS.child(userID).observe( .value, with: { (user) in
                            
                            loggedInUserData = user.value as? [String: Any]
                            
                            
                        })
                    }
                }
                
            }
        }
    }
    
    var firstStartup = true
    var loggedInComplete = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainscreen = self
        
        hospitalTable.delegate = self
        hospitalTable.dataSource = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startMonitoringSignificantLocationChanges()
        locationStatus()
        functionButtons = [feedbackButton,updateStatusButton,administrativeToolsButton, changeHospitalButton]
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        _ = KeychainWrapper.standard.removeAllKeys()
//        if firstStartup {
//            firstStartup = false
//            if let userID = KeychainWrapper.standard.string(forKey: USER_UID) {
//            
//                loggedInUserID = userID
//                
//                DataService.ds.REF_USERS.child(userID).observe( .value, with: { (user) in
//                    
//                    loggedInUserData = user.value as? [String: Any]
//                    
//                    
//                })
//            }
//        }
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

        DataService.ds.REF_HOSPITALS.queryOrderedByKey().observe(.value, with: { (snapshot) in
            hospitalsArray = [NO_HOSPITAL, EBS_Struct]

            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                
                for snap in snapshot {
                    let hospital = HospitalStruct(hospitalSnap: snap)
                    if hospital.name == loggedHospitalName {
                        loggedInUserHospital = hospital
                    }
                    hospitalsArray.append(hospital)
                }
            }
            sortHospitalsToNetworksAndLevels()
            
            self.hospitalTable.reloadData()
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
        if userData != nil {
            loggedHospitalName = (userData?["hospital"] as! String)
        }
        if signedIn {
//            if hospitalsArray.count == 2 {
//                userLabel.text = "Unable to access the Database"
//                self.activityIndicator.startAnimating()
//                self.prepareDataBase {
//                    self.activityIndicator.stopAnimating()
//                    self.stack.isHidden = false
//                }
//            } else {
            
                loggedInUserHospital = hospitalsArray[hospitalsArray.index(where: { (HospitalStruct) -> Bool in
                    return HospitalStruct.name == loggedHospitalName
                })!]
                userLabel.text = "Currently Logged in as - \((userData?["firstName"])!) \((userData?["surname"])!)"
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
//            }
        }   else {
            userLabel.text = "Currently Logged in as - Guest User"
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
    
    //MARK: PickerView Delegate and Ultimate user functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hospitalsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hospitalTable.dequeueReusableCell(withIdentifier: "hospitalCellmainVC")
        cell?.textLabel?.text = hospitalsArray[indexPath.row].name
        
        return cell!
    }
    
    @IBAction func changeHospitalPressed(_ sender: Any) {
        if hospitalTable.isHidden {
            hospitalTable.isHidden = false
            hospitalTable.selectRow(at: IndexPath(row: hospitalsArray.index(where: { (HospitalStruct) -> Bool in
                return HospitalStruct.name == loggedHospitalName
            })!, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.none)
            
            hospitalTable.scrollToRow(at: IndexPath (row: hospitalsArray.index(where: { (HospitalStruct) -> Bool in
                return HospitalStruct.name == loggedHospitalName
            })!, section: 0), at: UITableViewScrollPosition.none, animated: true)
            
            changeHospitalButton.setTitle("Confirm", for: .normal)
            changeHospitalButton.backgroundColor = UIColor(red: 81/255, green: 164/255, blue: 1, alpha: 1)
            changeHospitalButton.setTitleColor(UIColor.white, for: .normal)

        }   else {
            hospitalTable.isHidden = true
            if hospitalTable.indexPathForSelectedRow != nil {
                loggedInUserHospital = hospitalsArray[(hospitalTable.indexPathForSelectedRow?.row)!]
            }
            loggedHospitalName = loggedInUserHospital?.name
            loggedInUserData?["hospital"] = loggedHospitalName!
            changeHospitalButton.setTitle("Change Hospital", for: .normal)
            changeHospitalButton.backgroundColor = .white
            changeHospitalButton.setTitleColor(UIColor.darkGray, for: .normal)
            toggleSignInButton(signedIn: true, userData: loggedInUserData)
        }
    }
    
}

