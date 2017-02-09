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

class MainVC: UIViewController, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

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
    @IBOutlet weak var hospitalPicker: UIPickerView!
    
    var locationManager = CLLocationManager()
    var myLocation: CLLocation? {
        didSet{
            currentLocation = myLocation
            self.activityIndicator.startAnimating()
            self.prepareDataBase {
                self.activityIndicator.stopAnimating()
                self.stack.isHidden = false
                if !self.loggedInComplete {
                    if loggedInUserData != nil {
                        self.toggleSignInButton(signedIn: true, userData: loggedInUserData)
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
        
        hospitalPicker.delegate = self
        hospitalPicker.dataSource = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startMonitoringSignificantLocationChanges()
        locationStatus()
        functionButtons = [feedbackButton,updateStatusButton,administrativeToolsButton, changeHospitalButton]
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        _ = KeychainWrapper.standard.removeAllKeys()
        if firstStartup {
            firstStartup = false
            if let userID = KeychainWrapper.standard.string(forKey: USER_UID) {
            
                loggedInUserID = userID
                
                DataService.ds.REF_USERS.child(userID).observe( .value, with: { (user) in
                    
                    loggedInUserData = user.value as? [String: Any]
                    
                    if hospitalsArray.count > 2 {
                        
                        self.loggedInComplete = true
                        self.toggleSignInButton(signedIn: true, userData: loggedInUserData)
                        
                    }
                })
            }
        }
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
            
            self.hospitalPicker.reloadAllComponents()
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hospitalsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return hospitalsArray[row].name
    }
    
    @IBAction func changeHospitalPressed(_ sender: Any) {
        if hospitalPicker.isHidden {
            hospitalPicker.isHidden = false
            hospitalPicker.selectRow(hospitalsArray.index(where: { (HospitalStruct) -> Bool in
                return HospitalStruct.name == loggedHospitalName
            })!, inComponent: 0, animated: true)
            changeHospitalButton.setTitle("Confirm", for: .normal)
            changeHospitalButton.backgroundColor = UIColor(red: 81/255, green: 164/255, blue: 1, alpha: 1)
            changeHospitalButton.setTitleColor(UIColor.white, for: .normal)

        }   else {
            hospitalPicker.isHidden = true
            loggedInUserHospital = hospitalsArray[hospitalPicker.selectedRow(inComponent: 0)]
            loggedHospitalName = loggedInUserHospital?.name
            loggedInUserData?["hospital"] = loggedHospitalName!
            changeHospitalButton.setTitle("Change Hospital", for: .normal)
            changeHospitalButton.backgroundColor = .white
            changeHospitalButton.setTitleColor(UIColor.darkGray, for: .normal)
            toggleSignInButton(signedIn: true, userData: loggedInUserData)
        }
    }
    
}

