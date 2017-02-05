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


typealias DownloadComplete = () -> ()

let locationManager = CLLocationManager()

var currentHospital: HospitalStruct?
var hospitalsArray = [HospitalStruct(name: "", address: "", location: CLLocation(latitude: 0, longitude: 0), network: "", level: 0, distanceFromMe: 0, subspecialty: "", switchBoard: "", nicuNumber: "", nicuCoordinator: "", labourWard: "")]
var sortedHospitalsArray = [[[HospitalStruct]]]()
var currentLocation: CLLocation!
var selectedHospital: HospitalStruct?
var currentNetwork: Int?
let networks = ["North Central & East London Neonatal", "North West London Neonatal", "South London Neonatal"]


let USER_UID = "uid"

var loggedInUserID: String?
var loggedInUserData: [String:String]?
var loggedInUserHospital: HospitalStruct?

func sortHospitalsToNetworksAndLevels() {
    
    var hospitalsListed = hospitalsArray
    hospitalsListed.removeFirst()
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
