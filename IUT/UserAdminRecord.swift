//
//  UserAdminRecord.swift
//  IUT
//
//  Created by Ahmed Zaima on 13/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import Foundation
import  Firebase

class UserAdminRecord {
    let email: String
    let firstName: String
    let surname: String
    let key: String
    
    var admin: Bool?
    var updateCots: Bool?
    var superUser: Bool?
    
    init(userFileSnap: FIRDataSnapshot){
        key = userFileSnap.key
        let snapValue = userFileSnap.value as! [String: Any]
        let userDetails = snapValue["details"]! as! [String: String]
        
        email = userDetails["email"]!
        firstName = userDetails["firstName"]!
        surname = userDetails["surname"]!
        
        if let userEntitlements = snapValue["entitlements"] as? [String:String]{
            admin = userEntitlements["admin"] == "true"
            updateCots = userEntitlements["updateCots"] == "true"
            superUser = userEntitlements["superUser"] == "true"
            
        }
        
    }
}
