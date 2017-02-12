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
    
    
    private var _REF_REGIONS = DB_BASE.child("regions")
    private var _REF_HOSPITALS = DB_BASE.child("Hospitals")
    private var _REF_HOSPITAL_BY_REGION = DB_BASE.child("hospitalsByRegion")
    private var _REF_HOSPITALS_ARCHIVE = DB_BASE.child("hospitalArchive")
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_USER_BYHOSPITAL = DB_BASE.child("userByHospital")
    private var _REF_COT_STATUS_ARCHIVE = DB_BASE.child("cotStatusArchive")
    
    private var _REF_FEEDBACK = DB_BASE.child("feedback")
    private var _REF_FEEDBACK_ARCHIVE = DB_BASE.child("feedbackArchive")
    
    var REF_REGIONS: FIRDatabaseReference {
        return _REF_REGIONS
    }
    
    var REF_HOSPITALS: FIRDatabaseReference {
        return _REF_HOSPITALS
    }
    
    var REF_HOSPITALS_BY_REGION: FIRDatabaseReference {
        return _REF_HOSPITAL_BY_REGION
    }
    
    var REF_HOSPITALS_ARCHIVE: FIRDatabaseReference {
        return _REF_HOSPITALS_ARCHIVE
    }
    
    var REF_COT_STATUS_ARCHIVE: FIRDatabaseReference {
        return _REF_COT_STATUS_ARCHIVE
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_USER_BYHOSPITAL: FIRDatabaseReference {
        return _REF_USER_BYHOSPITAL
    }
    
    var REF_FEEDBACK: FIRDatabaseReference {
        return _REF_FEEDBACK
    }
    
    var REF_FEEDBACK_ARCHIVE: FIRDatabaseReference {
        return _REF_FEEDBACK_ARCHIVE
    }
    
    
    
    func createFireBaseDBUser(uid: String, region: String, hospital: String, userData: [String: Any]) {
        
        REF_USERS.child(uid).updateChildValues(userData)
        
        REF_USER_BYHOSPITAL.child(country).child(region).child(hospital).updateChildValues([uid: ["name": "\((userData["firstName"])!) \((userData["surname"])!)", "newUser": "true"]])
        
    }
    
    func updateUserProfile(uid: String, userData: [String: Any], wasNew: Bool) {
        REF_USERS.child(uid).updateChildValues(userData)
        if wasNew {
            REF_USERS.child(uid).child("newUser").removeValue()
        }
        
        REF_USER_BYHOSPITAL.child(country).child(loggedInUserRegion).child(loggedHospitalName!).child(uid).updateChildValues((userData["entitlementsReviewed"] as! [String: Any]))
        REF_USER_BYHOSPITAL.child(country).child(loggedInUserRegion).child(loggedHospitalName!).child(uid).updateChildValues(["newUser": "false"])
    }
    
    func changeUserHospital(oldHospital: String, newHospital: String) {
        REF_USERS.child(loggedInUserID!).updateChildValues(["hospital": newHospital, "newUser": "true", "superUser": "false", "adminRights": "false", "statusRights": "false" ])
        
        REF_USER_BYHOSPITAL.child(country).child(loggedInUserRegion).child(oldHospital).child(loggedInUserID!).removeValue()
        REF_USER_BYHOSPITAL.child(country).child(loggedInUserRegion).child(newHospital).child(loggedInUserID!).updateChildValues(["name": "\((loggedInUserData?["firstName"])!) \((loggedInUserData?["surname"])!)", "newUser": "true"])
    }
    
    func createFeedbackMessage(hospital: String, userID: String, title: String, body: String, hospitalFrom: String) {
        formatter.dateFormat = "dd-MM-yy HH:mm"
        let message = [
        "body": body,
        "user": userID,
        "username": "\(((loggedInUserData?["firstName"] as! String).characters.first)!). \(loggedInUserData?["surname"] as! String) (\(hospitalFrom))"]
        REF_FEEDBACK.child(country).child(loggedInUserRegion).child(hospital).child("\(title) - (\(formatter.string(from: date)))").updateChildValues(message)
    }
    
    func createHospitalEntry(name: String, hospitalData: [String:Any]) {
        
        if hospitalsArray.contains(where: { (HospitalStruct) -> Bool in
            return HospitalStruct.name == name
        }) {
            REF_HOSPITALS_BY_REGION.child(country).child(loggedInUserRegion).child(name).observeSingleEvent(of: .value, with: { (snapshot) in
                var oldHospitalData = snapshot.value as! [String: Any]
                oldHospitalData["archivedBy"] = loggedInUserID
                
                self.REF_HOSPITALS_ARCHIVE.child(country).child(loggedInUserRegion).child("\(formatter.string(from: date)) \(name)").updateChildValues(oldHospitalData)
                
            })
        
        }
        
        self.REF_HOSPITALS_BY_REGION.child(country).child(loggedInUserRegion).child(name).updateChildValues(hospitalData)

    }
    
    func archiveFeedback( title: String, message: [String: Any]){
        REF_FEEDBACK_ARCHIVE.child(country).child(loggedInUserRegion).child(loggedInUserData?["hospital"] as! String).child(title).updateChildValues(message)
        REF_FEEDBACK.child(country).child(loggedInUserRegion).child(loggedInUserData?["hospital"] as! String).child(title).removeValue()
    }
    
    func updateCotStatus(hospital: String, cots: Int){
        REF_HOSPITALS_BY_REGION.child(country).child(loggedInUserRegion).child(hospital).child("cotStatus").observeSingleEvent(of: .value, with: { (statusSnapshot) in
            if var previousStatus = statusSnapshot.value as? [String: Any] {
                let key = previousStatus["update"] as! String
                previousStatus["update"] = nil
                self.REF_COT_STATUS_ARCHIVE.child(country).child(loggedInUserRegion).child(hospital).child(key).updateChildValues(previousStatus)
            }
            formatter.dateFormat = "dd-MM-yy HH:mm"
            let newStatus = ["cotsAvailable": cots, "update": formatter.string(from: date), "updateBy": loggedInUserID! ] as [String : Any]
            self.REF_HOSPITALS_BY_REGION.child(country).child(loggedInUserRegion).child(hospital).child("cotStatus").updateChildValues(newStatus)
        })
    }
    
    func createRegion (country: String, region: String, networks: [String]) {
        REF_REGIONS.child(country).updateChildValues([region: networks])
    }
    
}
