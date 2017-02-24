//
//  Constants.swift
//  IUT
//
//  Created by Ahmed Zaima on 31/01/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

func removeBackButton (_ viewController: UIViewController, title: String?) {
    
    if let topItem = viewController.navigationController?.navigationBar.topItem {
        let titleStr = title == nil ? "" : title!
        topItem.backBarButtonItem = UIBarButtonItem(title: titleStr, style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
}

let date = Date()
let formatter = DateFormatter()

var loggedIn = false

typealias DownloadComplete = () -> ()

let locationManager = CLLocationManager()

var currentHospital: HospitalStruct?

let NO_HOSPITAL = HospitalStruct(name: "(None)", address: "", location: CLLocation(latitude: 0, longitude: 0), network: "", level: 0, distanceFromMe: 0, subspecialty: "", switchBoard: "", nicuNumber: "", nicuCoordinator: "", labourWard: "")
let EBS_Struct = HospitalStruct(name: "E B S", address: "", location: CLLocation(latitude: 0, longitude: 0), network: "", level: 0, distanceFromMe: 0, subspecialty: "", switchBoard: "", nicuNumber: "", nicuCoordinator: "", labourWard: "")

var hospitalsArray = [NO_HOSPITAL, EBS_Struct]
var sortedHospitalsArray = [[[HospitalStruct]]]()
var currentLocation: CLLocation!
var selectedHospital: HospitalStruct?
var currentNetwork: Int?


var hospitalsListing = [HospitalStruct]()

let USER_UID = "uid"

var mainscreen: MainVC?

var country = ""
var allRegions = [String: Any]()
var regions = [String: Any]()
var networks = [String]()
var subSpecialtyList = [String]()

var loggedInUserID: String?
var loggedInUserRegion = ""
var loggedInUserData: [String:Any]? {
    didSet{
        mainscreen?.toggleSignInButton(signedIn: true, userData: loggedInUserData)
    }
}


var loggedInUserHospital: HospitalStruct? {
    didSet{
        if mainscreen !== nil {
            
            if loggedInUserHospital?.name != "(None)" && loggedInUserHospital?.name != "E B S" && loggedInUserData?["viewCotStatus"] as? String == "true" {
                
                mainscreen?.cotStatusLabel.isHidden = false
                
                if loggedInUserHospital?.cotsAvailable != nil {
                    
                    mainscreen?.cotStatusLabel.text = "You currently have \((loggedInUserHospital?.cotsAvailable)!) cots available\nLast updated \((loggedInUserHospital?.cotsUpdate)!)"
                }   else {
                    mainscreen?.cotStatusLabel.text = "Your cot status has never been updated"
                }
                
            }
        }
    }
}


var loggedHospitalName: String?

func sortHospitalsToNetworksAndLevels() {
    
    var hospitalsListed = hospitalsArray
    
    hospitalsListed.removeFirst(2)
    hospitalsListing = hospitalsListed
    print("Started sorting")
    
    var sortedHospitals = Array(repeating: Array(repeatElement([HospitalStruct](), count: 3)), count: networks.count)
    for hospital in hospitalsListed {
        
        sortedHospitals[networks.index(of: hospital.network)!][hospital.level - 1].append(hospital)
    }
    sortedHospitalsArray = sortedHospitals
    
    
}
