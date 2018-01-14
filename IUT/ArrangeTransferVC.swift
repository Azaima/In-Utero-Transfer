//
//  ArrangeTransferVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 11/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import UIKit
import CoreLocation

class ArrangeTransferVC: UIViewController, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    let alertMessage = UIAlertController(title: nil, message: "", preferredStyle: UIAlertControllerStyle.alert)
    
    @IBOutlet weak var sourceSearch: UISearchBar!
    @IBOutlet weak var selectedHospitalLabel: UILabel!
    @IBOutlet weak var hospitalPickerStack: UIStackView!
    @IBOutlet weak var hospitalPicker: UIPickerView!
    @IBOutlet weak var gestationSelector: UISegmentedControl!
    @IBOutlet weak var medicalDiseaseSearch: UISearchBar!
    @IBOutlet weak var inNetworkTable: UITableView!
    @IBOutlet weak var outOfNetworkTable: UITableView!
    @IBOutlet weak var outOfRegionTable: UITableView!
    @IBOutlet weak var linkHospitalBtn: UIButton!
    @IBOutlet weak var selectHospitalBtn: UIButton!
    @IBOutlet weak var hospInNetworkLabel: UILabel!
    
    @IBOutlet var inNetworkTap: UITapGestureRecognizer!
    @IBOutlet var outOfNetworkTap: UITapGestureRecognizer!
    @IBOutlet var outOfRegionTap: UITapGestureRecognizer!
    
    
    var hospitalSearchList = [HospitalStructure]()
    var inNetworkList = [HospitalStructure]()
    var outOfNetworkList = [[HospitalStructure]]()
    var outOfRegionList = [[HospitalStructure]]()
    var hospitalsInCountry = [String:[String:[HospitalStructure]]]()
    var networks = Set <String>()
    var regions = Set <String>()
    var medical = ""
    
    var sourceHospital: HospitalStructure? {
        didSet{
            if sourceHospital != nil {
                selectedHospitalLabel.text = "\(sourceHospital!.name!) selected."
                setPickerVisibility(as: false)
                network = sourceHospital!.network!
                let hospitalsOfSameCountry = hospitals.filter({ (hospital: HospitalStructure) -> Bool in
                    return hospital.country == sourceHospital!.country
                })
                
                networks = []
                regions = []
                for hospital in hospitalsOfSameCountry {
                    networks.insert(hospital.network)
                    regions.insert(hospital.region)
                    hospital.distance = CLLocation(latitude: hospital.location.latitude, longitude: hospital.location.longitude).distance(from: CLLocation(latitude: (sourceHospital?.location.latitude)!, longitude: (sourceHospital?.location.longitude)!))
                }
                
                for region in regions {
                    var regionHosps = [String: [HospitalStructure]]()
                    
                    for network in networks {
                    
                        regionHosps[network] = hospitalsOfSameCountry.filter({ (hospital: HospitalStructure) -> Bool in
                            return hospital.region == region && hospital.network == network
                        })
                    }
                    
                    hospitalsInCountry[region] = regionHosps
                    
                }
                
                sortHospitals()
            }
        }
    }
    var network = "" {
        didSet{
            hospInNetworkLabel.text = "Hospitals in \(network) network"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertMessage.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        removeBackButton(self, title: nil)
        
        sourceSearch.delegate = self
        medicalDiseaseSearch.delegate = self
        
        hospitalPicker.delegate = self
        hospitalPicker.dataSource = self
        
        let tables = [inNetworkTable, outOfNetworkTable, outOfRegionTable]
        
        for table in tables {
            table?.delegate = self
            table?.dataSource = self
        }
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar == sourceSearch {
            if let text = searchBar.text {
                searchForHospital(text: text)
            }
        }   else {
            if let med = medicalDiseaseSearch.text {
                medical = med
                sortHospitals()
            }
        }
    }
    
    func setPickerVisibility(as visibility: Bool){
        hospitalPickerStack.isHidden = !visibility
        selectedHospitalLabel.isHidden = visibility
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchForHospital(text: String){
        if text != "" {
            hospitalSearchList = hospitals.filter({ (hospital: HospitalStructure) -> Bool in
                return hospital.name.lowercased().contains(text.lowercased())
            })
        }   else {
            hospitalSearchList = []
        }
        hospitalPicker.reloadComponent(0)
        setPickerVisibility(as: true)
    }

    //    MARK: GA selection
    
    @IBAction func gaSelected(_ sender: Any) {
        sortHospitals()
    }
    
    //    MARK: Picker view setup
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return hospitalSearchList[row].name
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        setPickerVisibility(as: hospitalSearchList.isEmpty)
        return hospitalSearchList.count
    }
    
    //    MARK: Select source Hospital
    
    @IBAction func selectHospitalPressed(_ sender: UIButton) {
        sourceSearch.resignFirstResponder()
        if sender == linkHospitalBtn {
            
            sourceHospital = userData["hospitalStructure"] as? HospitalStructure
        }   else {
            if !hospitalSearchList.isEmpty {
                sourceHospital = hospitalSearchList[hospitalPicker.selectedRow(inComponent: 0)]
            }   else {
                alertMessage.message = "Error: Unable to select hospital."
                present(alertMessage, animated: true, completion: nil)
                return
            }
        }
    }

    func  sortHospitals() {
        if sourceHospital != nil {
            var level = 0
            switch gestationSelector.selectedSegmentIndex {
            case 0:
                level = 3
            case 1:
                level = 2
            default:
                level = 1
            }
        
            inNetworkList = sortLevelAndDistance(list: hospitalsInCountry[(sourceHospital!.region)]![sourceHospital!.network]!, level: level)
        
            outOfNetworkList = [[]]
            for network in networks {
                if network != sourceHospital!.network {
                    if let networkList = hospitalsInCountry[sourceHospital!.region]![network] {
                        outOfNetworkList.append(sortLevelAndDistance(list: networkList, level: level))
                    }
                }
            }
        
            outOfRegionList = [[]]
            for region in regions {
                if region != sourceHospital!.region {
                    var regionArray = [HospitalStructure]()
                    for (_, network) in hospitalsInCountry[region]! {
                            regionArray.append(contentsOf: sortLevelAndDistance(list: network, level: level))
                    }
                    outOfRegionList.append(regionArray.sorted(by: { (hospitalA: HospitalStructure, hospitalB: HospitalStructure) -> Bool in
                        return hospitalA.distance! < hospitalB.distance!
                    }))
                }
            }
        
            inNetworkTable.reloadData()
            outOfNetworkTable.reloadData()
            outOfRegionTable.reloadData()
        }
    }
    
    func sortLevelAndDistance(list: [HospitalStructure], level: Int) -> [HospitalStructure]{
        var filtered = list.filter({ (hospital: HospitalStructure) -> Bool in
            return hospital.level >= level && hospital.key != sourceHospital!.key
        })
        
        if medical != "" {
            filtered = filtered.filter({ (hospital: HospitalStructure) -> Bool in
                return hospital.subspecialty.lowercased().contains(medical.lowercased())
            })
        }
        
        let sorted = filtered.sorted(by: { (hospitalA: HospitalStructure, hospitalB: HospitalStructure) -> Bool in
            return hospitalA.level < hospitalB.level || hospitalA.distance! < hospitalB.distance!
        })
        return sorted
    }
    
    //    MARK: Tableview functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView {
        case inNetworkTable:
            return 1
        case outOfNetworkTable:
            return outOfNetworkList.count
        default:
            return outOfRegionList.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case inNetworkTable:
            return inNetworkList.count
        case outOfNetworkTable:
            return outOfNetworkList[section].count
        default:
            return outOfRegionList[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HospitalCell") as! HospitalCell
        var hospital: HospitalStructure
        switch tableView {
        case inNetworkTable:
            hospital = inNetworkList[indexPath.row]
        case outOfNetworkTable:
            hospital = outOfNetworkList[indexPath.section][indexPath.row]
        default:
            hospital = outOfRegionList[indexPath.section][indexPath.row]
        }
        
        cell.initCell(hospital: hospital)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch tableView {
        case inNetworkTable:
            return nil
        case outOfNetworkTable:
            return outOfNetworkList[section].first?.network
        default:
            return outOfRegionList[section].first?.region
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var hospital: HospitalStructure
        switch tableView {
        case inNetworkTable:
            hospital = inNetworkList[indexPath.row]
        case outOfNetworkTable:
            hospital = outOfNetworkList[indexPath.section][indexPath.row]
        default:
            hospital = outOfRegionList[indexPath.section][indexPath.row]
        }
        
        performSegue(withIdentifier: "hospitalDetails", sender: hospital)
    }
    
    @IBAction func labelTapped(_ sender: UITapGestureRecognizer) {
        
        switch sender {
        case inNetworkTap:
            inNetworkTable.isHidden = !inNetworkTable.isHidden
        case outOfNetworkTap:
            outOfNetworkTable.isHidden = !outOfNetworkTable.isHidden
        default:
            outOfRegionTable.isHidden = !outOfRegionTable.isHidden
        }
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! HospitalCotDetailsVC
        destination.hospital = sender as? HospitalStructure
    }
    

}
