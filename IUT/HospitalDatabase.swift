//
//  HospitalDatabase.swift
//  IUT
//
//  Created by Ahmed Zaima on 11/03/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import Foundation
import Firebase

class HospitalDatabase {
    
    var data = [String:Any]()
    var regionData = [String: Any]()
    var hospitalData: [String:Any]?
    var hospitalNames = [String]()
    
    var selectedCountry = ""
    var selectedRegion = ""
    var selectedHospital = ""
    
    var dataFromRegions = [String: Any]()
    
    func getHospitalDatabase(completed: @escaping DownloadComplete){
        DataService.ds.REF_HOSPITALS_BY_REGION.observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            if let database = dataSnapshot.children.allObjects as? [FIRDataSnapshot] {
                for dataEntry in database {
                    self.data[dataEntry.key] = dataEntry.value as! [String:Any]
                }
                
            }
            
            DataService.ds.REF_REGIONS.observeSingleEvent(of: .value, with: { (regionSnap) in
                
                self.dataFromRegions = regionSnap.value as! [String: Any]
                
                completed()
            })
            
        })
    }
    
    func selectCountry(index: Int) {
        regionData = dataFromRegions.sorted(by: { (entry1: (key: String, value: Any), entry2: (key: String, value: Any)) -> Bool in
            return entry1.key < entry2.key
        })[index].value as! [String:Any]
        selectedCountry = dataFromRegions.sorted(by: { (entry1: (key: String, value: Any), entry2: (key: String, value: Any)) -> Bool in
            return entry1.key < entry2.key
        })[index].key

    }
    
    func selectRegion(index: Int) {
        selectedRegion = regionData.sorted(by: { (entry1: (key: String, value: Any), entry2: (key: String, value: Any)) -> Bool in
            return entry1.key < entry2.key
        })[index].key
        
        if data[selectedCountry] != nil && (data[selectedCountry] as! [String:Any])[selectedRegion] != nil {
            hospitalData = (data[selectedCountry] as! [String:Any])[selectedRegion] as? [String: Any]
            
            hospitalNames = ["(None)", "E B S"]
            
            for hosp in hospitalData!.sorted(by: { (e1: (key: String, value: Any), e2: (key: String, value: Any)) -> Bool in
                return e1.key < e2.key
            }) {
                hospitalNames.append(hosp.key)
            }
        }
    }

}
