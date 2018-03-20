//
//  Constants.swift
//  IUT
//
//  Created by Ahmed Zaima on 31/01/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

var homePage: HomePageVC?
let DB_BASE = FIRDatabase.database().reference()
let COTFINDER2_REF = FIRDatabase.database().reference().child("cotfinder2")

var hospitals = [HospitalStructure]() {
    didSet {
        hospitals.sort { (a: HospitalStructure, b: HospitalStructure) -> Bool in
            return a.name < b.name
        }
    }
}

var userData = [String: Any]()


let ad = UIApplication.shared.delegate as! AppDelegate
let context = ad.persistentContainer.viewContext

var sessionData: (email: String, password: String, uid: String)?
let date = Date()
let dateFormatter = DateFormatter()


func removeBackButton (_ viewController: UIViewController, title: String?) {
    
    if let topItem = viewController.navigationController?.navigationBar.topItem {
        let titleStr = title == nil ? "" : title!
        topItem.backBarButtonItem = UIBarButtonItem(title: titleStr, style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
}

typealias DownloadComplete = () -> ()

func getGreeting () -> String {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH"
    
    let hour = Int(dateFormatter.string(from: date))
    if hour! < 12 {
        return "morning"
    }   else if hour! < 17 {
        return "afternoon"
    }   else {
        return "evening"
    }
}

var markers = [String: MKAnnotationView]()

var cotStatusRecords = [String: CotStatusRecord]()

func getCotStatus(for key: String, outcome: String) -> String {
    
    if let cotStatusRecord = cotStatusRecords[key]{
        dateFormatter.dateFormat = "dd-MM-yy HH:mm"
        
        var status = "Found record but unable to retrieve update"
        var hospital: HospitalStructure
        if let index = hospitals.index(where: { (hospital: HospitalStructure) -> Bool in
            return hospital.key == key
        }){
            hospital = hospitals[index]
            if let cotIndex = cotStatusRecord.updates.index(where: { (update) -> Bool in
                return update.key == cotStatusRecord.lastUpdate.key
            }){
                let cotUpdate = cotStatusRecord.updates[cotIndex]
                
                if outcome == "details" {
                    status = "Updated at \(cotUpdate.timeStr!))"
                    status += "\n- SCBU: \(cotUpdate.scbu!)"
                    status = hospital.level > 1 ? status + "\n- NICU: \(cotUpdate.nicu!)" : status
                    status = hospital.level > 2 ? status + "\n- Subspecialty: \(cotUpdate.subspecialty!)" : status
                    status += "\n\(cotUpdate.comments!)"
                }   else {
                    status = "\((cotUpdate.scbu) + (cotUpdate.nicu) + (cotUpdate.subspecialty)) cots available at \(cotUpdate.timeStr!))"
                }
            }
        }
        
        
        
        return status
    }   else {
        return "Cot Status has never been updated"
    }
    
   
}

func stringToDate(dateString: String) -> Date? {
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "dd-MM-yy HH:mm"
    
    let date = dateformatter.date(from: dateString)
    return date
}


