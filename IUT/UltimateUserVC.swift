//
//  UltimateUserVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 11/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit
import Firebase

class UltimateUserVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var countryTable: UITableView!
    @IBOutlet weak var regionTable: UITableView!
    @IBOutlet weak var hospitalTable: UITableView!
    @IBOutlet weak var regionStack: UIStackView!
    @IBOutlet weak var hospitalStack: UIStackView!
    @IBOutlet weak var selectHospitalLabel: UILabel!
    
    var tables = [UITableView]()
    
    var data = [String:Any]()
    var regionData = [String: Any]()
    var hospitalData: [String:Any]?
    var hospitalNames = [String]()
    
    var selectedCountry = ""
    var selectedRegion = ""
    var selectedHospital = ""
    
    var dataFromRegions = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tables = [countryTable, regionTable, hospitalTable]
        for table in tables {
            table.delegate = self
            table.dataSource = self
        }
        
        removeBackButton(self, title: nil)
        getHospitalDatabase {
            self.countryTable.reloadData()
        }
    }

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
    
    @IBAction func confirmSelectionPressed(_ sender: Any) {
        
        if selectedCountry != "" && selectedRegion != ""  {
            
            selectedHospital = selectedHospital == "" ? "(None)" : selectedHospital
            country = selectedCountry
            loggedInUserRegion = selectedRegion
            loggedHospitalName = selectedHospital
            
            mainscreen?.prepareDataBase {
                let dict = ["country": self.selectedCountry, "region": self.selectedRegion, "hospital": self.selectedHospital] 
                for entry in dict {
                    loggedInUserData?[entry.key] = entry.value
                }

                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: Table View Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case countryTable:
            return dataFromRegions.count
            
        case regionTable:
            return regionData.count
        default:
            if hospitalData == nil {
                return 0
            }   else {
                return hospitalNames.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusedCell")
        
        var dictInUse = [String:Any]()
        
        switch tableView {
        case countryTable:
            dictInUse = dataFromRegions
            
        case regionTable:
            dictInUse = regionData
        default:
            if hospitalData == nil {
                dictInUse = [:]
            }   else {
                cell?.textLabel?.text = hospitalNames[indexPath.row]
                return cell!
                
            }
        }
        
        let dictInUseSorted =  dictInUse.sorted(by: { (entry1: (key: String, value: Any), entry2: (key: String, value: Any)) -> Bool in
            return entry1.key < entry2.key
        })
        
        cell?.textLabel?.text = dictInUseSorted[indexPath.row].key
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case countryTable:
            regionData = dataFromRegions.sorted(by: { (entry1: (key: String, value: Any), entry2: (key: String, value: Any)) -> Bool in
                return entry1.key < entry2.key
                })[indexPath.row].value as! [String:Any]
            selectedCountry = dataFromRegions.sorted(by: { (entry1: (key: String, value: Any), entry2: (key: String, value: Any)) -> Bool in
                return entry1.key < entry2.key
            })[indexPath.row].key
            regionStack.isHidden = false
            regionTable.reloadData()

        case regionTable:
            
            selectedRegion = regionData.sorted(by: { (entry1: (key: String, value: Any), entry2: (key: String, value: Any)) -> Bool in
                return entry1.key < entry2.key
            })[indexPath.row].key
            
            if data[selectedCountry] != nil && (data[selectedCountry] as! [String:Any])[selectedRegion] != nil {
                hospitalData = (data[selectedCountry] as! [String:Any])[selectedRegion] as? [String: Any]
                
                hospitalNames = ["(None)", "E B S"]
                
                for hosp in hospitalData!.sorted(by: { (e1: (key: String, value: Any), e2: (key: String, value: Any)) -> Bool in
                    return e1.key < e2.key
                }) {
                    hospitalNames.append(hosp.key)
                }
            }
            hospitalStack.isHidden = false
            if hospitalData == nil || (hospitalData?.isEmpty)! {
                hospitalTable.isHidden = true
                selectHospitalLabel.text = "No hospitals available in region"
            }   else {
                hospitalTable.reloadData()
                hospitalTable.isHidden = false
                selectHospitalLabel.text = "Select Hospital"
            }
        default:
            selectedHospital = hospitalNames[indexPath.row]
        }
    }
}
