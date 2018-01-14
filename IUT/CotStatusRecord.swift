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
    
    var lastUpdate: (key: String, time: Date, user: String)!
    var updates = [CotStatus]()
    
    init (recordSnap: FIRDataSnapshot){
        let recordChildren = recordSnap.children.allObjects as! [FIRDataSnapshot]
        
        for snap in recordChildren {
            if snap.key == "lastUpdate" {
                let lastRecord = snap.value as! [String: String]
                
                lastUpdate = (key: lastRecord["key"]!, time: stringToDate(dateString: lastRecord["time"]!), user: lastRecord["user"]!)
            }   else {
                let update = CotStatus(updateSnap: snap)
                updates.append(update)
            }
        }
        
        updates.sort { (updateA, updateB) -> Bool in
            return updateA.time < updateB.time
        }
    }
}
