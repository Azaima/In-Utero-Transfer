//
//  CotStatus.swift
//  IUT
//
//  Created by Ahmed Zaima on 09/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import Foundation
import Firebase

class CotStatus {
    let key: String!
    let inHouse: Int!
    let inNetwork: Int!
    let nicu: Int!
    let scbu: Int!
    let subspecialty: Int!
    let comments: String!
    var time: Date?
    let user: String!
    var timeStr: String?
    
    init(updateSnap: FIRDataSnapshot){
        let update = updateSnap.value as! [String : Any]
        key = updateSnap.key
        inHouse = update["inHouse"] as! Int
        inNetwork = update["inNetwork"] as! Int
        nicu = update["nicu"] as! Int
        scbu = update["scbu"] as! Int
        subspecialty = update["subspecialty"] as! Int
        comments = update["comments"] as! String
        user = update["user"] as! String
        if let timeAsDate = stringToDate(dateString: update["time"] as! String) {
            time = timeAsDate
        }
        timeStr = update["time"] as? String
        
    }
    
}
