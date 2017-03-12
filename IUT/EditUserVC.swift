//
//  EditUserVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 11/03/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit
import Firebase

class EditUserVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {

    @IBOutlet weak var userNameLAbel: UILabel!
    @IBOutlet weak var linkHospitalLabel: UILabel!
    
    @IBOutlet weak var ultimateUserSwitch: UISwitch!
    @IBOutlet weak var superUserSwitch: UISwitch!
    @IBOutlet weak var adminRightsSwitch: UISwitch!
    @IBOutlet weak var feedbackSwitch: UISwitch!
    @IBOutlet weak var updateCotsSwitch: UISwitch!
    @IBOutlet weak var viewCotsSwitch: UISwitch!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryTable: UITableView!
    
    @IBOutlet weak var selectHospitalLabel: UILabel!
    @IBOutlet weak var regionsStack: UIStackView!
    @IBOutlet weak var selectRegionLabel: UILabel!
    @IBOutlet weak var regionTable: UITableView!
    @IBOutlet weak var hospitalStack: UIStackView!
    @IBOutlet weak var hospitalTable: UITableView!
    
    var userData = [String:Any]()
    var userID = ""
    
    var userHospitalData = [String:Any]()
    
    
    let hospitalsData = HospitalDatabase()
    
    var tables = [UITableView]()
    
    var alert = UIAlertController(title: "Delete User", message: "You are about to delete the User", preferredStyle: UIAlertControllerStyle.alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.destructive, handler: { (UIAlertAction) in
            
            DataService.ds.REF_USERS.child(self.userID).removeValue()
            
            DataService.ds.REF_USER_BYHOSPITAL.child(self.userHospitalData["country"] as! String).child(self.userHospitalData["region"] as! String).child(self.userHospitalData["hospital"] as! String).child(self.userID).removeValue()
            _ = self.navigationController?.popViewController(animated: true)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        tables = [countryTable, regionTable, hospitalTable]
        for table in tables {
            table.delegate = self
            table.dataSource = self
        }

        setupData()
        removeBackButton(self, title: "Cancel")
        hospitalsData.getHospitalDatabase {
            
            self.countryTable.reloadData()
        }
    }

    func setupData() {
        userNameLAbel.text = "\(userData["firstName"]!) \(userData["surname"]!)"
        linkHospitalLabel.text = "\(userData["hospital"]!)"
        
        userHospitalData["hospital"] = userData["hospital"]!
        userHospitalData["region"] = userData["region"]!
        userHospitalData["country"] = userData["country"]!
        
        ultimateUserSwitch.isOn = userData["ultimateUser"] as? String == "true"
        superUserSwitch.isOn = userData["superUser"] as? String == "true"
        adminRightsSwitch.isOn = userData["adminRights"] as? String == "true"
        feedbackSwitch.isOn = userData["feedbackRights"] as? String == "true"
        updateCotsSwitch.isOn = userData["statusRights"] as? String == "true"
        viewCotsSwitch.isOn = userData["viewCotStatus"] as? String == "true"
        
    }
    
    // MARK: Tableview Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case countryTable:
            return hospitalsData.dataFromRegions.count
            
        case regionTable:
            return hospitalsData.regionData.count
            
        default:
            if hospitalsData.hospitalData == nil {
                return 0
            }   else {
                return hospitalsData.hospitalNames.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusedCell")
        
        var dictInUse = [String:Any]()
        
        switch tableView {
        case countryTable:
            dictInUse = hospitalsData.dataFromRegions
            
        case regionTable:
            dictInUse = hospitalsData.regionData
        default:
            if hospitalsData.hospitalData == nil {
                dictInUse = [:]
            }   else {
                cell?.textLabel?.text = hospitalsData.hospitalNames[indexPath.row]
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
            hospitalsData.selectCountry(index: indexPath.row)
            regionsStack.isHidden = false
            regionTable.reloadData()
            
        case regionTable:
            
            hospitalsData.selectRegion(index: indexPath.row)
            hospitalStack.isHidden = false
            if hospitalsData.hospitalData == nil || (hospitalsData.hospitalData?.isEmpty)! {
                hospitalTable.isHidden = true
                selectHospitalLabel.text = "No hospitals available in region"
            }   else {
                hospitalTable.reloadData()
                hospitalTable.isHidden = false
                selectHospitalLabel.text = "Select Hospital"
            }
        default:
            hospitalsData.selectedHospital = hospitalsData.hospitalNames[indexPath.row]
            
            userData["country"] = hospitalsData.selectedCountry
            userData["region"] = hospitalsData.selectedRegion
            userData["hospital"] = hospitalsData.selectedHospital
            
            linkHospitalLabel.text = hospitalsData.selectedHospital
            hospitalStack.isHidden = true
            regionsStack.isHidden = true
            countryTable.isHidden = true
            countryLabel.text = "Change User Hospital"
        }
    }
    
    @IBAction func changeLinkHospitalPressed(_ sender: Any) {
        countryTable.isHidden = false
        countryLabel.text = "Select Country"
    }
    
    @IBAction func updateUserData(_ sender: UIBarButtonItem) {
        if userData["hospital"] as! String != userHospitalData["hospital"] as! String {
            DataService.ds.hospitalChangeByUtimateUser(userID: userID, userName: userNameLAbel.text!, oldData: userHospitalData as! [String : String], newData: ["hospital": userData["hospital"] as! String, "region": userData["region"] as! String, "country": userData["country"] as! String])
        }
        
        userData["ultimateUser"] = ultimateUserSwitch.isOn ? "true" : "false"
        userData["superUser"] = superUserSwitch.isOn ? "true" : "false"
        userData["adminRights"] = adminRightsSwitch.isOn ? "true" : "false"
        userData["feedbackRights"] = feedbackSwitch.isOn ? "true" : "false"
        userData["statusRights"] = updateCotsSwitch.isOn ? "true" : "false"
        userData["viewCotStatus"] = viewCotsSwitch.isOn ? "true" : "false"
        userData["newUser"] = "false"
            
        DataService.ds.profileUpdateByUltimateUser(userID: userID, data: userData)
        
        DataService.ds.REF_USER_BYHOSPITAL.child(userData["country"] as! String).child(userData["region"] as! String).child(userData["hospital"] as! String).child(userID).updateChildValues(["newUser": "false"])
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteUserPressed(_ sender: UIButton) {
        present(alert, animated: true, completion: nil)
    }
}
