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

class MainVC: UIViewController, CLLocationManagerDelegate {

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
    
    var locationManager = CLLocationManager()
    var myLocation: CLLocation? {
        didSet{
            currentLocation = myLocation
            self.activityIndicator.startAnimating()
            self.prepareDataBase {
                self.activityIndicator.stopAnimating()
                self.stack.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startMonitoringSignificantLocationChanges()
        locationStatus()
        functionButtons = [feedbackButton,updateStatusButton,administrativeToolsButton]
    }
    
    override func viewDidAppear(_ animated: Bool) {
            if let userID = KeychainWrapper.standard.string(forKey: USER_UID) {
            
            loggedInUserID = userID
            
            DataService.ds.REF_USERS.child(userID).observeSingleEvent(of: .value, with: { (user) in
                
                loggedInUserData = user.value as? [String: String]
                self.toggleSignInButton(signedIn: true, userData: loggedInUserData)
                
                if loggedInUserData?["hospital"] != nil && loggedInUserData?["hospital"] != "" {
                    let hospitalName = (loggedInUserData?["hospital"])!
                    
                    loggedInUserHospital = hospitalsArray[hospitalsArray.index(where: { (HospitalStruct) -> Bool in
                        return HospitalStruct.name! == hospitalName
                    })!]
                    
                    self.userLabel.text = "\((self.userLabel.text)!)\nUser is linked to \((loggedInUserHospital?.name)!)"
                        
                    }
                
                
                
            })
            
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
            hospitalsArray = [HospitalStruct(name: "", address: "", location: CLLocation(latitude: 0, longitude: 0), network: "", level: 0, distanceFromMe: 0, subspecialty: "", switchBoard: "", nicuNumber: "", nicuCoordinator: "", labourWard: "")]

            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                print("Ahmed: I have \(snapshot.count) snaps")
                for snap in snapshot {
                    let hospital = HospitalStruct(hospitalSnap: snap)
                    hospitalsArray.append(hospital)
                }
            }
            
            print("Ahmed: And I have \(hospitalsArray.count) hospitals")
            if loggedInUserData?["hospital"] != "" && loggedInUserData?["hospital"] != nil {
                print(loggedInUserData?["hospital"])
                loggedInUserHospital = hospitalsArray[hospitalsArray.index(where: { (HospitalStruct) -> Bool in
                    return HospitalStruct.name == loggedInUserData?["hospital"]
                })!]
                print(loggedInUserHospital?.name)
            }
            
            sortHospitalsToNetworksAndLevels()
            
            complete()

        })
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignInVC" {
            let destination = segue.destination as! SignInVC
            destination.register = sender as! Bool
            destination.mainVC = self
        }
    }

    @IBAction func signinPressed(_ sender: UIButton) {
        let register = sender.tag == 1 ? true : false
        performSegue(withIdentifier: "SignInVC", sender: register)
    }
    
    func toggleSignInButton(signedIn: Bool, userData: [String:String]?) {
        
        signInButton.isHidden = signedIn
        registerButton.isHidden = signedIn
        signOutButton.isHidden = !signedIn
        if signedIn {
            userLabel.text = "Currently Logged in as - \((userData?["firstName"])!) \((userData?["surname"])!)"
            feedbackButton.isHidden = false
            if userData?["updateStatus"] != nil {
                updateStatusButton.isHidden = false
            }
            
            if userData?["administrativeRights"] != nil {
                administrativeToolsButton.isHidden = false
            }
        }   else {
            userLabel.text = "Currently Logged in as - Guest User"
            for button in functionButtons {
                button.isHidden = true
            }
        }
    }
    
    @IBAction func signOutPressed(_ sender: UIButton) {
        KeychainWrapper.standard.removeObject(forKey: USER_UID)
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
}

