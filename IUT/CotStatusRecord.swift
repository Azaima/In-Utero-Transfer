//
//  CotStatus.swift
//  IUT
//
//  Created by Ahmed Zaima on 09/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import Foundation
import Firebase

class CotStatusRecord {
    
    var lastUpdate: (key: String, time: Date?, user: String, timeStr: String)!
    var updates = [CotStatus]()
    
    init (recordSnap: FIRDataSnapshot){
        let recordChildren = recordSnap.children.allObjects as! [FIRDataSnapshot]
        
        for snap in recordChildren {
            if snap.key == "lastUpdate" {
                let lastRecord = snap.value as! [String: String]
                if let timeAsDate = stringToDate(dateString: lastRecord["time"]!) {
                    let time = timeAsDate
                    lastUpdate = (key: lastRecord["key"]!, time: time, user: lastRecord["user"]!, timeStr: lastRecord["time"]!)
                }   else {
                    lastUpdate = (key: lastRecord["key"]!, time: nil, user: lastRecord["user"]!, timeStr: lastRecord["time"]!)
                }
                
                
            }   else {
                let update = CotStatus(updateSnap: snap)
                updates.append(update)
            }
        }
        
        if !updates.isEmpty && updates[0].time != nil {
            updates.sort { (updateA, updateB) -> Bool in
                return updateA.time! < updateB.time!
            }
        }
    }
}
