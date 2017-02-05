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
    private var _REF_HOSPITALS_ARCHIVE = DB_BASE.child("hospitalArchive")
    private var _REF_USERS = DB_BASE.child("users")
    
    private var _REF_FEEDBACK = DB_BASE.child("feedback")
    private var _REF_FEEDBACK_ARCHIVE = DB_BASE.child("feedbackArchive")
    
    
    var REF_HOSPITALS: FIRDatabaseReference {
        return _REF_HOSPITALS
    }
    
    var REF_HOSPITALS_ARCHIVE: FIRDatabaseReference {
        return _REF_HOSPITALS_ARCHIVE
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_FEEDBACK: FIRDatabaseReference {
        return _REF_FEEDBACK
    }
    
    var REF_FEEDBACK_ARCHIVE: FIRDatabaseReference {
        return _REF_FEEDBACK_ARCHIVE
    }
    
    
    
    func createFireBaseDBUser(uid: String, userData: [String: String]) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func createFeedbackMessage(hospital: String, userID: String, title: String, body: String) {
        formatter.dateFormat = "dd-MM-yy HH:mm"
        let message = [
        "body": body,
        "user": userID]
        REF_FEEDBACK.child(hospital).child("\(title) - (\(formatter.string(from: date)))").updateChildValues(message)
    }
    
    func createHospitalEntry(name: String, hospitalData: [String:Any]) {
        
        if hospitalsArray.contains(where: { (HospitalStruct) -> Bool in
            return HospitalStruct.name == name
        }) {
            REF_HOSPITALS.child(name).observeSingleEvent(of: .value, with: { (snapshot) in
                var oldHospitalData = snapshot.value as! [String: Any]
                oldHospitalData["archivedBy"] = loggedInUserID
                
                self.REF_HOSPITALS_ARCHIVE.child("\(formatter.string(from: date)) \(name)").updateChildValues(oldHospitalData)
            })
            
            
        }
        
        REF_HOSPITALS.child(name).updateChildValues(hospitalData)
    }
    
}
