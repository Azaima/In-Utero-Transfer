//
//  DataService.swift
//  IUT
//
//  Created by Ahmed Zaima on 31/01/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = FIRDatabase.database().reference()

class DataService {
    
    static let ds = DataService()
    
    
    private var _REF_HOSPITALS = DB_BASE.child("Hospitals")
    private var _REF_USERS = DB_BASE.child("users")
    
    
    var REF_HOSPITALS: FIRDatabaseReference {
        return _REF_HOSPITALS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    func createFireBaseDBUser(uid: String, userData: Dictionary<String,String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
}
