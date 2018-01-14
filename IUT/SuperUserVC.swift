//
//  SuperUserVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 14/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import UIKit
import Firebase

class SuperUserVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var hospitalSearchBar: UISearchBar!
    @IBOutlet weak var hospitalsTable: UITableView!
    
    var hospitalSearchList = [HospitalStructure](){
        didSet{
            hospitalsTable.reloadData()
        }
    }
    
    var usersRecordsDictionary = [String: [FIRDataSnapshot]](){
        didSet{
            hospitalsTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeBackButton(self, title: nil)
        getUsersList()
        hospitalsTable.delegate = self
        hospitalsTable.dataSource = self
        hospitalSearchBar.delegate = self
        
        
    }

    func getUsersList(){
        COTFINDER2_REF.child("usersByHospital").observe(FIRDataEventType.value, with: { (snapshot) in
            if let allHospitalsSnapList = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for hospitalSnapshot in allHospitalsSnapList {
                    self.usersRecordsDictionary[hospitalSnapshot.key] = hospitalSnapshot.children.allObjects as? [FIRDataSnapshot]
                }
            }
        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hospitalSearchList.isEmpty {
            return hospitals.count
        }   else {
            return hospitalSearchList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuperUserHospitalDetailsCell") as! SuperUserHospitalDetailsCell
        
        if hospitalSearchList.isEmpty {
            cell.initCell(hospital: hospitals[indexPath.row], updateRecord: cotStatusRecords[hospitals[indexPath.row].key], usersRecords: usersRecordsDictionary[hospitals[indexPath.row].key])
        }   else {
            cell.initCell(hospital: hospitalSearchList[indexPath.row], updateRecord: cotStatusRecords[hospitalSearchList[indexPath.row].key], usersRecords: usersRecordsDictionary[hospitalSearchList[indexPath.row].key])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SuperUserHospitalDetailsCell
        performSegue(withIdentifier: cell.targetVC, sender: cell)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text?.lowercased(){
            hospitalSearchList = hospitals.filter({ (hospital) -> Bool in
                return hospital.name.lowercased().contains(searchText)
            }).sorted(by: { (hospitalA, hospitalB) -> Bool in
                return hospitalA.name < hospitalB.name
                
            })
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? SuperUserHospitalDetailsCell {
            switch cell.targetVC {
            case "EditHospitalDetailsVC":
                let destination = segue.destination as! EditHospitalDetailsVC
                destination.hospital = cell.hospital
                
            case "HospitalAdminVC":
                let destination = segue.destination as! HospitalAdminVC
                destination.hospital = cell.hospital
                
            default:
                let destination = segue.destination as! UpdateCotsVC
                destination.hospital = cell.hospital
            }
        }
    }
    

}
