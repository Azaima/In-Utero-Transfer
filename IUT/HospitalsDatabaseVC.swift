//
//  HospitalsDatabaseVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 04/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit

class HospitalsDatabaseVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var newHospitalButton: UIBarButtonItem!
    @IBOutlet weak var hospitalsTable: UITableView!
    
    var updatingCotStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        removeBackButton(self, title: nil)
        hospitalsTable.delegate = self
        hospitalsTable.dataSource = self
        
        newHospitalButton.isEnabled = !updatingCotStatus
        
        DataService.ds.REF_HOSPITALS_BY_REGION.observe(.value, with: { (snapShot) in
            self.hospitalsTable.reloadData()
        })
    
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return networks.count * 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sortedHospitalsArray[section / 3][section % 3].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(networks[section / 3]) - Level\(section % 3 + 1)"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HospitalCell")
        
        cell?.textLabel?.textAlignment = .center
        cell?.textLabel?.text = sortedHospitalsArray[indexPath.section / 3][indexPath.section % 3][indexPath.row].name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hospital = sortedHospitalsArray[indexPath.section / 3][indexPath.section % 3][indexPath.row]
        performSegue(withIdentifier: "HospitalDetailsVC", sender: hospital)
    }
    
    @IBAction func addHospitalPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "HospitalDetailsVC", sender: sender)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! HospitalDetailsVC
        if sender is UIBarButtonItem {
            destination.newHospital = true
        }   else {
            destination.hospital = sender as? HospitalStruct
        }
        destination.updatingCotStatus = updatingCotStatus
    }
   

}
