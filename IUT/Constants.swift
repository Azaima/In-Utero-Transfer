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
let networks = ["North Central & East London Neonatal", "North West London Neonatal", "South London Neonatal"]
let networksForHeaders = ["North Central & East", "North West", "South"]
var hospitalsListing = [HospitalStruct]()

let USER_UID = "uid"

var loggedInUserID: String?
var loggedInUserData: [String:Any]?
var loggedInUserHospital: HospitalStruct?

func sortHospitalsToNetworksAndLevels() {
    
    var hospitalsListed = hospitalsArray
    
    hospitalsListed.removeFirst(2)
    hospitalsListing = hospitalsListed
    print("Started sorting")
    
    var sortedHospitals = Array(repeating: Array(repeatElement([HospitalStruct](), count: 3)), count: 3)
    for hospital in hospitalsListed {
        print(hospital.name)
        sortedHospitals[networks.index(of: hospital.network)!][hospital.level - 1].append(hospital)
    }
    sortedHospitalsArray = sortedHospitals
    
    for (index,network) in sortedHospitalsArray.enumerated() {
        print("\(networks[index])")
        for (levelIndex,level) in network.enumerated() {
            print("Level \(levelIndex + 1)")
            for hospital in level {
                print(hospital.name)
            }
        }
    }
}
