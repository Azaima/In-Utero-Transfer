//
//  SourceOfTransferVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 06/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit
import CoreLocation

class SourceOfTransferVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var selectHospital: UISegmentedControl!
    @IBOutlet weak var gaSelector: UISegmentedControl!
    @IBOutlet weak var hospitalsTable: UITableView!
    @IBOutlet weak var careNotAvailableLabel: UILabel!
    @IBOutlet weak var medicalDisordersSelector: UISegmentedControl!
    @IBOutlet weak var medicalDisordersPicker: UIPickerView!
    
    var suggestedHospital: HospitalStruct?
    var hospitalSelected = false
    var hospListForTable = [[HospitalStruct]]()
    
    var locationManager = CLLocationManager()
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hospitalsTable.delegate = self
        hospitalsTable.dataSource = self
        
        medicalDisordersPicker.delegate = self
        medicalDisordersPicker.dataSource = self
        
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
                        closestHospital = hospital
                    }   else {
                        if currentLocation.distance(from: hospital.location) < closestDistance! {
                            closestDistance = currentLocation.distance(from: hospital.location)
                            closestHospital = hospital
                        }
                    }
                }
            }
            
            if !foundHospital {
                updateLabel(foundHospital: false, hospital: closestHospital)
            }
        }   else {
            locationLabel.text = "Unable to detect location"
        }
    }
    
    func updateLabel(foundHospital: Bool, hospital: HospitalStruct?){
        
        suggestedHospital = hospital
        if hospital != nil {
            if foundHospital {
                locationLabel.text = "You are currently in \((hospital?.name)!)"
                selectHospital.setTitle("Use Current Hospital", forSegmentAt: 0)
                
            }   else if !foundHospital && loggedIn && loggedInUserHospital?.name != "E B S" && loggedInUserHospital?.name != "(None)" {
                locationLabel.text = "You currently are not in a hospital.\nWould you like to use your link hospital?"
                selectHospital.setTitle("Use Link Hospital", forSegmentAt: 0)
                
                suggestedHospital = loggedInUserHospital
            }   else {
                locationLabel.text = "You currently are not in a hospital. The closest hospital is \((hospital?.name)!).\nWould you like to use this hospital?"
                selectHospital.setTitle("Use Suggested Hospital", forSegmentAt: 0)
                
            }
            
            selectHospital.isHidden = false
        } else {
            
            locationLabel.text = "Unable to provide a suggested hospital"
        }
        if hospitalsListing.isEmpty {
            locationLabel.text = "\(locationLabel.text!)\n There seems to be a problem with obtaining the data"
        }
    }
    
    // MARK: Select the source Hospital
    
    @IBAction func hospitalSelected(_ sender: Any) {
        if selectHospital.selectedSegmentIndex == 0 {
            currentHospital = suggestedHospital
            selectHospital.isHidden = true
            hospitalSelected = true
            updateHospitalsDistance()
            gaSelector.isHidden = false
            
            locationLabel.text = "\((currentHospital?.name)!) selected as source of transfer.\nYour hospital is part of the \((currentHospital?.network)!) network."
            hospitalsTable.isHidden = true
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
            return hospListForTable.count
        }   else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hospitalSelected {
            if !hospListForTable.isEmpty && !hospListForTable[section].isEmpty {
                return hospListForTable[section].count
            }   else {
                return 0
            }
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
            if !hospListForTable.isEmpty && !hospListForTable[section].isEmpty {
                return hospListForTable[section][0].network!
            }
        }
        
        return nil
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hospitalSelected {
            performSegue(withIdentifier: "viewHospitalInfo", sender: hospListForTable[indexPath.section][indexPath.row])
            
        }   else {
            currentHospital = hospitalsListing[indexPath.row]
            locationLabel.text = "\((currentHospital?.name)!) selected as source of transfer.\nYour hospital is part of the \((currentHospital?.network)!) network."
            hospitalSelected = true
            
            hospitalsTable.isHidden = true
            selectHospital.isHidden = true
            gaSelector.isHidden = false
            updateHospitalsDistance()
        }
    }
    
    //MARK: select gestational age
    
    @IBAction func gestationalAgeSelected(_ sender: UISegmentedControl) {
        medicalDisordersSelector.isHidden = false
        var careAvailable = false
        var hospitalsTemp = Array(repeating: [HospitalStruct](), count: sortedHospitalsArray.count)
        for net in 0 ... sortedHospitalsArray.count - 1 {
            for level in 2 - gaSelector.selectedSegmentIndex ... 2 {
                
                hospitalsTemp[net] += sortedHospitalsArray[net][level].sorted(by: { (hosp1: HospitalStruct, hosp2: HospitalStruct) -> Bool in
                    return hosp1.distanceFromMe! < hosp2.distanceFromMe!
                })
                
            }
        }
        var myNetwork = hospitalsTemp.remove(at: networks.index(of: (currentHospital?.network)!)!)

        if myNetwork.contains(where: { (HospitalStruct) -> Bool in
            return HospitalStruct === currentHospital
        }){
            myNetwork.remove(at: myNetwork.index(where: { (HospitalStruct) -> Bool in
                return HospitalStruct === currentHospital
            })!)
        }
        
        hospListForTable = [myNetwork] + hospitalsTemp.sorted(by: { (net1: [HospitalStruct], net2: [HospitalStruct]) -> Bool in
            if net1.isEmpty {
                return false
            } else if net2.isEmpty {
                return true
            }   else {
                return net1[0].distanceFromMe! < net2[0].distanceFromMe!
            }
        })
        
        for network in hospListForTable {
            
            careAvailable = !network.isEmpty ? true : careAvailable
        }
        
        hospitalsTable.isHidden = !careAvailable
        careNotAvailableLabel.isHidden = careAvailable
        checkSubSpec()
        hospitalsTable.reloadData()
        hospitalsTable.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
    }
    
    func checkSubSpec() {
        if medicalDisordersSelector.selectedSegmentIndex == 1 {
            let subSpec = subSpecialtyList[medicalDisordersPicker.selectedRow(inComponent: 0)]
            for (index,list) in hospListForTable.enumerated() {
                let filteredList =  list.filter({ (h: HospitalStruct) -> Bool in
                    return h.subspecialty.lowercased().contains(subSpec.lowercased())
                })
                
                hospListForTable[index] = filteredList
            }
        }
    }
    
    @IBAction func medicalDisorderSelected (_ sender: UISegmentedControl) {
        medicalDisordersPicker.isHidden = medicalDisordersSelector.selectedSegmentIndex == 0
        medicalDisordersPicker.selectRow(0, inComponent: 0, animated: false)
        gestationalAgeSelected(gaSelector)
        
    }
    
    // MARK: PickerView Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return subSpecialtyList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return subSpecialtyList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gestationalAgeSelected(gaSelector)
    }
    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! HospitalDetailsVC
        destination.viewOnlyMode = true
        destination.hospital = sender as? HospitalStruct
        
    }
    

}
