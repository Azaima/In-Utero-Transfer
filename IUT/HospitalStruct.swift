//
//  HospitalStruct.swift
//  InUteroTransfer
//
//  Created by Ahmed Zaima on 04/01/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import Foundation
import CoreLocation

class HospitalStruct {
    
    let location: CLLocation!
    let name: String!
    let network: String!
    let level: Int!
    let address: String!
    let subspeciality: String?
    var distanceFromMe: Double!
    let labourWard: String!
    
    let switchBoard: String!
    let nicuNumber: String!
    let nicuCoordinator: String?
    
    init (name: String, address: String, location: CLLocation, network: String, level: Int, distanceFromMe: Double, subspeciality: String?, switchBoard: String,  nicuNumber: String, nicuCoordinator: String?, labourWard: String ){
        
        self.name = name
        self.location = location
        self.level = level
        self.address = address
        self.network = network
        self.distanceFromMe = distanceFromMe
        self.subspeciality = subspeciality
        self.switchBoard = switchBoard
        self.nicuNumber = nicuNumber
        self.nicuCoordinator = nicuCoordinator
        self.labourWard = labourWard
    }
    
}

