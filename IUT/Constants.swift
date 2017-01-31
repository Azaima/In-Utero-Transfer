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

typealias DownloadComplete = () -> ()

let locationManager = CLLocationManager()

var currentHospital: HospitalStruct?
var hospitalsArray = [HospitalStruct(name: "", address: "", location: CLLocation(latitude: 0, longitude: 0), network: "", level: 0, distanceFromMe: 0, subspeciality: "", switchBoard: "", nicuNumber: "", nicuCoordinator: "", labourWard: "")]
var sortedHospitalsArray = [[[HospitalStruct]]]()
var currentLocation: CLLocation!
var selectedHospital: HospitalStruct?
var currentNetwork: Int?

let USER_UID = "uid"
