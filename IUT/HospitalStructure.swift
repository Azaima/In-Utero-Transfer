//
//  HospitalStructure.swift
//  IUT
//
//  Created by Ahmed Zaima on 09/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import MapKit

class HospitalStructure {
    
    let key: String!
    let address: String!
    let location: CLLocationCoordinate2D!
    let level: Int!
    let country: String!
    let region: String!
    let network: String!
    let labourWard: String!
    let nicu: String!
    let nicuCoordinator: String!
    let subspecialty: String!
    let switchBoard: String!
    let name: String!
    var distance: CLLocationDistance?
    
    var updates = [String: [String: String]]()
    let mark: HospitalMarker?
    var markView = MKAnnotationView()
    
    init(hospitalSnap: FIRDataSnapshot) {
        let hospitalDetails = hospitalSnap.value as! [String: Any]
        
        key = hospitalSnap.key
        address = hospitalDetails["address"] as! String
        location = CLLocationCoordinate2D(latitude: (hospitalDetails["location"] as! [String: Double])["latitude"]!, longitude: (hospitalDetails["location"] as! [String: Double])["longitude"]!)
        level = hospitalDetails["level"] as! Int
        country = hospitalDetails["country"] as! String
        region = hospitalDetails["region"] as! String
        network = hospitalDetails["network"] as! String
        labourWard = hospitalDetails["labourWard"] as! String
        nicu = hospitalDetails["nicu"] as! String
        nicuCoordinator = hospitalDetails["nicuCoordinator"] as! String
        subspecialty = hospitalDetails["subspecialty"] as! String
        switchBoard = hospitalDetails["switchBoard"] as! String
        name = hospitalDetails["name"] as! String
        
        if let fileUpdate = hospitalDetails["address"] as? [String : [String: String]] {
            updates = fileUpdate
        }
        
        mark = HospitalMarker(coordinate: location, key: hospitalSnap.key, title: name, subtitle: nil, level: level)
    }
    
}
