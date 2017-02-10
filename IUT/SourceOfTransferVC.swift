//
//  SourceOfTransferVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 06/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit
import CoreLocation

class SourceOfTransferVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var selectHospital: UISegmentedControl!
    @IBOutlet weak var gaSelector: UISegmentedControl!
    @IBOutlet weak var hospitalsTable: UITableView!
    
    var suggestedHospital: HospitalStruct?
    var hospitalSelected = false
    var hospListForTable = [[HospitalStruct]]()
    
    var locationManager = CLLocationManager()
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hospitalsTable.delegate = self
        hospitalsTable.dataSource = self
        
        removeBackButton(self, title: nil)
        checkLocation()
    }

    // MARK: Check location
    
    func checkLocation(){
        location = locationManager.location
        
        var foundHospital = false
        var closestDistance: Double?
        var closestHospital: HospitalStruct?
        
        if location != nil {
            for hospital in hospitalsListing {
                if currentLocation.distance(from: hospital.location) < 1000 {
                    currentHospital = hospital
                    updateLabel(foundHospital: true, hospital: hospital)
                    foundHospital = true
                    break
                }   else {
                    if closestDistance == nil {
                        closestDistance = currentLocation.distance(from: hospital.location)
                    }   else {
                        if currentLocation.distance(from: hospital.location) < closestDistance! {
                            closestDistance = currentLocation.distance(from: hospital.location)
                            closestHospital = hospital
                        }
                    }
                }
            }
            
            if !foundHospital {
                updateLabel(foundHospital: false, hospital: closestHospital!)
            }
        }
    }
    
    func updateLabel(foundHospital: Bool, hospital: HospitalStruct){
        
        suggestedHospital = hospital
        
        if foundHospital {
            locationLabel.text = "You are currently in \((hospital.name)!)"
            selectHospital.setTitle("Use Current Hospital", forSegmentAt: 0)
            
        }   else if !foundHospital && loggedIn && loggedInUserHospital?.name != "E B S" && loggedInUserHospital?.name != "(None)" {
            locationLabel.text = "You currently are not in a hospital.\nWould you like to use your link hospital?"
            selectHospital.setTitle("Use Link Hospital", forSegmentAt: 0)
            
            suggestedHospital = loggedInUserHospital
        }   else {
            locationLabel.text = "You currently are not in a hospital. The closest hospital is \((hospital.name)!).\nWould you like to use this hospital?"
            selectHospital.setTitle("Use Suggested Hospital", forSegmentAt: 0)
            
        }
        
        selectHospital.isHidden = false
    }
    
    // MARK: Select the source Hospital
    
    @IBAction func hospitalSelected(_ sender: Any) {
        if selectHospital.selectedSegmentIndex == 0 {
            currentHospital = suggestedHospital
            selectHospital.isHidden = true
            hospitalSelected = true
            updateHospitalsDistance()
            gaSelector.isHidden = false
            locationLabel.text = "\((currentHospital?.name)!) selected as source of transfer"
        } else {
            hospitalsTable.isHidden = false
        }
    }
    
    func updateHospitalsDistance(){
        
        for hospital in hospitalsListing {
            hospital.distanceFromMe = currentHospital?.location.distance(from: hospital.location)
        }
        
    }
    
    // MARK: TableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if hospitalSelected {
            return 3
        }   else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hospitalSelected {
            return hospListForTable[section].count
        }   else {
            return hospitalsListing.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hospitalCell")
        if hospitalSelected {
            cell?.textLabel?.text = hospListForTable[indexPath.section][indexPath.row].name
        }   else {
            cell?.textLabel?.text = hospitalsListing[indexPath.row].name
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if hospitalSelected {
            return hospListForTable[section][0].network!
        }
        
        return nil
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hospitalSelected {
            performSegue(withIdentifier: "viewHospitalInfo", sender: hospListForTable[indexPath.section][indexPath.row])
            
        }   else {
            currentHospital = hospitalsListing[indexPath.row]
            locationLabel.text = "\((currentHospital?.name)!) selected as source of transfer"
            hospitalSelected = true
            
            hospitalsTable.isHidden = true
            selectHospital.isHidden = true
            gaSelector.isHidden = false
            updateHospitalsDistance()
        }
    }
    
    //MARK: select gestational age
    
    @IBAction func gestationalAgeSelected(_ sender: UISegmentedControl) {
        var hospitalsTemp = Array(repeating: [HospitalStruct](), count: 3)
        for net in 0 ... 2 {
            for level in gaSelector.selectedSegmentIndex ... 2 {
                hospitalsTemp[net] += sortedHospitalsArray[net][level].sorted(by: { (hosp1: HospitalStruct, hosp2: HospitalStruct) -> Bool in
                    return hosp1.distanceFromMe < hosp2.distanceFromMe
                })
            }
        }
        var myNetwork = hospitalsTemp.remove(at: hospitalsTemp.index(where: { (net: [HospitalStruct]) -> Bool in
            return net.contains(where: { (HospitalStruct) -> Bool in
                return HospitalStruct.network == currentHospital?.network
            })
        })!)
        if myNetwork.contains(where: { (HospitalStruct) -> Bool in
            return HospitalStruct === currentHospital
        }){
            myNetwork.remove(at: myNetwork.index(where: { (HospitalStruct) -> Bool in
                return HospitalStruct === currentHospital
            })!)
        }
        
        hospListForTable = [myNetwork] + hospitalsTemp.sorted(by: { (net1: [HospitalStruct], net2: [HospitalStruct]) -> Bool in
            return net1[0].distanceFromMe < net2[0].distanceFromMe
        })
        hospitalsTable.isHidden = false
        hospitalsTable.reloadData()
        hospitalsTable.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
    }
    
    
    
    
    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! HospitalDetailsVC
        destination.viewOnlyMode = true
        destination.hospital = sender as? HospitalStruct
        
    }
    

}
