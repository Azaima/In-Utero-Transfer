//
//  HospitalStruct.swift
//  InUteroTransfer
//
//  Created by Ahmed Zaima on 04/01/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class HospitalStruct {
    
    let location: CLLocation!
    let name: String!
    let network: String!
    let level: Int!
    let address: String!
    var subspecialty = ""
    var distanceFromMe: Double!
    let labourWard: String!
    
    let switchBoard: String!
    let nicuNumber: String!
    var nicuCoordinator = ""
    
    init (name: String, address: String, location: CLLocation, network: String, level: Int, distanceFromMe: Double, subspecialty: String?, switchBoard: String,  nicuNumber: String, nicuCoordinator: String?, labourWard: String ){
        
        self.name = name
        self.location = location
        self.level = level
        self.address = address
        self.network = network
        self.distanceFromMe = distanceFromMe
        self.subspecialty = subspecialty!
        self.switchBoard = switchBoard
        self.nicuNumber = nicuNumber
        self.nicuCoordinator = nicuCoordinator!
        self.labourWard = labourWard
    }
    
    init(hospitalSnap: FIRDataSnapshot ) {
        self.name = hospitalSnap.key
        let hospitalDetails = hospitalSnap.value as! [String: Any]
        
        self.address = hospitalDetails["address"] as! String
        self.labourWard = hospitalDetails["labourWard"] as! String
        self.level = hospitalDetails["level"] as! Int
        
        let hospitalLoc = CLLocation(latitude: (hospitalDetails["location"] as! [String: Double])["latitude"]!, longitude: (hospitalDetails["location"] as! [String: Double])["longitude"]!)
        self.location = hospitalLoc
        self.network = hospitalDetails["network"] as! String
        self.nicuNumber = hospitalDetails["nicu"] as! String
        self.switchBoard = hospitalDetails["switchBoard"] as! String
        if hospitalDetails["nicuCoordinator"] != nil {
            self.nicuCoordinator = hospitalDetails["nicuCoordinator"] as! String
        }
        if hospitalDetails["subspecialty"] != nil {
            self.subspecialty = hospitalDetails["subspecialty"] as! String
        }
        self.distanceFromMe = currentLocation.distance(from: hospitalLoc)
    }
    
}

