//
//  HospitalDetailsVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 04/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit

class HospitalDetailsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate {

    var newHospital = false
    var hospital: HospitalStruct?
    var updatingCotStatus = false
    var viewOnlyMode = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fullStack: UIStackView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var hospitalNameStack: UIStackView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    
    @IBOutlet weak var levelPicker: UIPickerView!
    
    @IBOutlet weak var subspecialityView: UITextView!
    
    @IBOutlet weak var geolocationStack: UIStackView!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var switchboardView: UITextView!
    @IBOutlet weak var labourWardView: UITextView!
    @IBOutlet weak var nicuView: UITextView!
    @IBOutlet weak var nicuCoordinatorView: UITextView!
    
    @IBOutlet weak var cotsStack: UIStackView!
    @IBOutlet weak var currentCotsLabel: UILabel!
    @IBOutlet weak var availableCotsField: UITextField!
    @IBOutlet weak var hospitalDetailsStack: UIStackView!
    
    @IBOutlet weak var networkTable: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var selectedNetworkLabel: UILabel!
    var fields = [UITextField]()
    var textViews = [UITextView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        networkTable.delegate = self
        networkTable.dataSource = self
        levelPicker.delegate = self
        levelPicker.dataSource = self

        fields = [nameField, latitudeField, longitudeField]
        textViews = [addressTextView, switchboardView, labourWardView, nicuView]
        var title = ""
        
        scrollView.contentSize.height = 2000
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        
        if viewOnlyMode {
            title = (hospital?.name)!
            setupFields()
            setupForViewOnly()
            removeBackButton(self, title: nil)
        }   else {
            cotsStack.isHidden = !updatingCotStatus
            hospitalDetailsStack.isHidden = updatingCotStatus
            
            
            
            
            if newHospital {
                title = "New hospital"
                
            }   else {
                title = "\((hospital?.name)!)"
                setupFields()
            }
            removeBackButton(self, title: "Cancel")
        }
        
        navigationBar.title = title
        scrollView.contentSize.height = fullStack.frame.height + 250
        
        
    }

    func setupForViewOnly(){
        doneButton.title = "FeedBack"
        if loggedHospitalName == nil {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
        availableCotsField.isHidden = true
        hospitalNameStack.isHidden = true
        networkTable.isUserInteractionEnabled = false
        levelPicker.isUserInteractionEnabled = false
        subspecialityView.isUserInteractionEnabled = false
        geolocationStack.isHidden = true
        selectedNetworkLabel.isUserInteractionEnabled = false
        
        
        for textview in textViews {
            textview.isEditable = false
            textview.dataDetectorTypes = .phoneNumber
        }
    }
    
    func setupFields() {
        hospitalNameStack.isHidden = true
        nameField.text = hospital?.name!
        addressTextView.text = hospital?.address!
        if !viewOnlyMode {
            networkTable.selectRow(at: IndexPath(row: networks.index(of: (hospital?.network)!)!, section: 0), animated: true, scrollPosition: .none)
        }
        
        selectedNetworkLabel.text = (hospital?.network)!
        
        levelPicker.selectRow((hospital?.level)! - 1, inComponent: 0, animated: true)
        subspecialityView.text = hospital?.subspecialty
        latitudeField.text = "\((hospital?.location.coordinate.latitude)!)"
        longitudeField.text = "\((hospital?.location.coordinate.longitude)!)"
        switchboardView.text = hospital?.switchBoard!
        labourWardView.text = hospital?.labourWard!
        nicuView.text = hospital?.nicuNumber!
        nicuCoordinatorView.text = hospital?.nicuCoordinator
        if hospital?.cotsAvailable != nil {
            currentCotsLabel.text = "\((hospital?.cotsAvailable)!) cots @ (\((hospital?.cotsUpdate)!))"
        }
    }
    
    func checkFields() -> Bool {
        for field in fields {
            if field.text == "" {
                field.backgroundColor = UIColor(red: 1, green: 205/255, blue: 210/255, alpha: 1)
                return false
            }
        }
        
        for textView in textViews {
            if textView.text == "" {
                textView.backgroundColor = UIColor(red: 1, green: 205/255, blue: 210/255, alpha: 1)
                return false
            }
        }
        
        if !checkCoordTextField(textField: latitudeField) {
            return false
        }
        
        if !checkCoordTextField(textField: longitudeField) {
            return false
        }
        
        if networkTable.indexPathForSelectedRow == nil {
            selectedNetworkLabel.backgroundColor = UIColor(red: 1, green: 205/255, blue: 210/255, alpha: 1)
            return false
        }
        
        return true
    }
    
    func checkCoordTextField(textField: UITextField) -> Bool {
        if let coordinateDegree = Double(textField.text!) {
            if coordinateDegree > -180, coordinateDegree < 180 {
                return true
            }
        }
    
        textField.backgroundColor = UIColor(red: 1, green: 205/255, blue: 210/255, alpha: 1)
        return false
        
        
    }
    
    //MARK: PickerDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
            return 3
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return "\(row + 1)"
        
    }
    
    
    //MARK: NetworkTable Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "networkCellHospDetails")
        cell?.textLabel?.text = networks[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        networkTable.isHidden = true
        selectedNetworkLabel.text = networks[indexPath.row]
        selectedNetworkLabel.backgroundColor = nil
    }
    
    @IBAction func networkLabelPressed(_ sender: UITapGestureRecognizer) {
        networkTable.isHidden = !networkTable.isHidden
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        if viewOnlyMode {
            performSegue(withIdentifier: "feedbackFromTransfer", sender: nil)
        }   else {
            if !updatingCotStatus {
                if checkFields() {
                    formatter.dateFormat = "dd-MM-yy HH:mm"
                    
                    let hospitalData = [
                    "address": addressTextView.text!,
                    "labourWard": labourWardView.text!,
                    "level": levelPicker.selectedRow(inComponent: 0) + 1,
                    "location": ["latitude": Double(latitudeField.text!), "longitude": Double(longitudeField.text!)],
                    "nicu": nicuView.text!,
                    "network": networks[(networkTable.indexPathForSelectedRow?.row)!],
                    "nicuCoordinator": nicuCoordinatorView.text,
                    "subspecialty": subspecialityView.text!,
                    "switchBoard": switchboardView.text!,
                    "lastUpdated": formatter.string(from: date),
                    "updatedBy": loggedInUserID!] as [String: Any]
                    
                    
                    DataService.ds.createHospitalEntry(name: nameField.text!, hospitalData: hospitalData)
                    
                    _ = navigationController?.popViewController(animated: true)
                }
            }   else {
                
                if let cots = Int(availableCotsField.text!) {
                    DataService.ds.updateCotStatus(hospital: (hospital?.name)!, cots: cots)
                    _ = navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
   
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! FeedbackVC
        destination.hospitalToFeedback = (hospital?.name!)!
        destination.messageFromTransfer = true
    }
    

}
