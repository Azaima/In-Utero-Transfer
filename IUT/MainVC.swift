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
    
    @IBOutlet weak var functionsStack: UIStackView!
    @IBOutlet weak var signinStack: UIStackView!
    
    var myLocation: CLLocation? {
        didSet{
            
            if allRegions.isEmpty {
                getregionsData()
            }   else {
                if myLocation != nil {
                    userLabel.text = "Initiating Application"
                    
                    currentLocation = myLocation
                    
                    if let userID = KeychainWrapper.standard.string(forKey: USER_UID) {
                        
                        loggedInUserID = userID
                        
                        DataService.ds.REF_USERS.child(userID).observe( .value, with: { (user) in
                            
                            if let dataObtained = user.value as? [String: Any] {
                                country = dataObtained["country"] as! String
                                loggedInUserRegion = dataObtained["region"] as! String
                                regions = allRegions[country] as! [String : Any]
                                
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
                            }   else {
                                self.unableToObtainData()
                            }

                            
                        })
                    } else {

                    
                        geocoder.reverseGeocodeLocation(myLocation!, completionHandler: { (locationName, error) in
                            if error == nil {
                                
                                if locationName != nil  {
                                    country = (locationName?[0].country)!
                                    let region = locationName?[0].subAdministrativeArea
                                    
                                    
                                    if allRegions[country] != nil {
                                            regions = allRegions[country] as! [String : Any]
                                    
                                            if regions[region!]  != nil {
                                                
                                                print("Ahmed: Region is London which is where you are")
                                                loggedInUserRegion = region!
                                                networks = regions[region!] as! [String]
                                            }   else if regions.count == 1 {
                                                for region in regions {
                                                    
                                                    loggedInUserRegion = region.key
                                                    networks = region.value as! [String]
                                                }
                                            }   else {
                                            
                                                print("Ahmed: You need to select a region")
                                                self.regionSelectionStack.isHidden = false
                                            }
                                            
                                            
                                            if loggedInUserRegion != "" {
                                                print("Ahmed: You are in the region \(loggedInUserRegion)")
                                                self.startPrepping()
                                            }
                                        
                                    }   else {
                                        self.regionSelectionStack.isHidden = false
                                        self.selectedRegionLabel.isUserInteractionEnabled = false
                                        self.selectedRegionLabel.text = "No regional data found for your Country.\nTo set up a new region please contact the admin team on azaima@outlook.com"
                                        self.stack.isHidden = false
                                        self.functionsStack.isHidden = true
                                        
                                        self.signinStack.isHidden = false
                                        self.signInButton.isHidden = false
                                        self.registerButton.isHidden = true
                                        self.editProfileButton.isHidden = true
                                        self.signOutButton.isHidden = true
                                            
                                        }
                                
                                }   else {
                                    print("Ahmed: locationName == nil")
                                }
                            }   else {
                                
                                print("Ahmed: Erorr != nil")
                                self.toggleSignInButton(signedIn: false, userData: nil)
                                self.stack.isHidden = false
                            }
                        })
                    }
                    
                    
                }   else {
                    
                    toggleSignInButton(signedIn: false, userData: nil)
                    self.stack.isHidden = false
                }
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
    
    // MARK: This is where it starts **************************************************************************
    // ********************************************************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainscreen = self
        functionButtons = [feedbackButton,updateStatusButton,administrativeToolsButton, changeHospitalButton]
        regionsTable.delegate = self
        regionsTable.dataSource = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startMonitoringSignificantLocationChanges()
        
        getregionsData()
    }
    
    func getregionsData() {
        DataService.ds.REF_REGIONS.observe(.value, with: { (regionsSnap) in
            
            if let regionsSnapshot = regionsSnap.value as? [String:Any] {
                allRegions = regionsSnapshot
                
                self.locationStatus()
            }   else {
                self.unableToObtainData()
            }
            
            DataService.ds.REF_SUBSPECIALITY.observeSingleEvent(of: .value, with: { (subspecSnap) in
                if let subSpec = subspecSnap.value as? [String] {
                    subSpecialtyList = subSpec.sorted()
                    subSpecialtyList.insert("- Scroll To Select -", at: 0)
                }   else {
                    print("Ahmed: Unable to get Subspec")
                }
            })
        })
    }
    
    func unableToObtainData() {
        userLabel.text = "Unable to obtain data from the server.\nPlease check your internet connection and restart the application."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//        insertNewDatabase()
        
//        _ = KeychainWrapper.standard.removeAllKeys()
        
//        correctHospital()
        
    }

    
    func correctHospital() {
        
        DataService.ds.REF_HOSPITALS_BY_REGION.child("United Kingdom").child("London").child("Kings College Hospital").observeSingleEvent(of: .value, with: { (kingsSnap) in
            if let data = kingsSnap.value as? [String:Any] {
                DataService.ds.REF_HOSPITALS_BY_REGION.child("United Kingdom").child("London").child("King's College Hospital").updateChildValues(data)
                DataService.ds.REF_HOSPITALS_BY_REGION.child("United Kingdom").child("London").child("Kings College Hospital").removeValue()
            }
        })
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        locationStatus()
    }
    
    func prepareDataBase(complete: @escaping DownloadComplete) {

        self.userLabel.text = "\(country) - \(loggedInUserRegion)"
        DataService.ds.REF_HOSPITALS_BY_REGION.child(country).child(loggedInUserRegion).queryOrderedByKey().observe(.value, with: { (snapshot) in
            hospitalsArray = [NO_HOSPITAL, EBS_Struct]

            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                
                for snap in snapshot {
                    let hospital = HospitalStruct(hospitalSnap: snap)

                    hospitalsArray.append(hospital)
                }
                
                networks = (allRegions[country] as! [String:Any])[loggedInUserRegion] as! [String]
                sortHospitalsToNetworksAndLevels()
                
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
        functionsStack.isHidden = false
        regionSelectionStack.isHidden = true
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
            if loggedHospitalName != "(None)" && userData?["statusRights"] as? String == "true" || userData?["superUser"] as? String == "true" || userData?["ultimateUser"] as? String == "true" {
                updateStatusButton.isHidden = false
                
                if loggedHospitalName != "E B S" && userData?["viewCotStatus"] as? String == "true"{
                    cotStatusLabel.isHidden = false

                    if loggedInUserHospital?.cotsAvailable != nil {
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
        loggedInUserData = nil
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegionCell")
        
        
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
    
    
}

