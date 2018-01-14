//
//  HospitalMarker.swift
//  IUT
//
//  Created by Ahmed Zaima on 08/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class HospitalMarker: NSObject, MKAnnotation  {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var key: String
    var level: Int
    
    init(coordinate: CLLocationCoordinate2D, key: String, title: String, subtitle: String?, level: Int) {
        self.coordinate = coordinate
        self.key = key
        self.level = level
        self.title = title
        if subtitle != nil {
            self.subtitle = subtitle
        }   else if key == "ebs-uk"{
            self.subtitle = "Contact EBS on 020 7407 4999."
        }   else {
            self.subtitle = getCotStatus(for: key, outcome: "brief")
        }
    }
    

}
