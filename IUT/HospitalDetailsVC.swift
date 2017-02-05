//
//  HospitalDetailsVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 04/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit

class HospitalDetailsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var newHospital = false
    var hospital: HospitalStruct?
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var hospitalNameStack: UIStackView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var networkPicker: UIPickerView!
    @IBOutlet weak var levelPicker: UIPickerView!
    @IBOutlet weak var subspecialityField: UITextField!
    @IBOutlet weak var geolocationStack: UIStackView!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var switchboardView: UITextView!
    @IBOutlet weak var labourWardView: UITextView!
    @IBOutlet weak var nicuView: UITextView!
    @IBOutlet weak var nicuCoordinatorView: UITextView!
    
    var fields = [UITextField]()
    var textViews = [UITextView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fields = [nameField, latitudeField, longitudeField]
        textViews = [addressTextView, switchboardView, labourWardView, nicuView]
        
        networkPicker.delegate = self
        networkPicker.dataSource = self
        levelPicker.delegate = self
        levelPicker.dataSource = self
        
        var title: String
        if newHospital {
            title = "Adding a new hospital"
            
        }   else {
            title = "Editing \((hospital?.name)!)"
            setupFields()
        }
        navigationBar.title = title
        removeBackButton(self, title: "Cancel")
        
    }

    func setupFields() {
        hospitalNameStack.isHidden = true
        nameField.text = hospital?.name!
        addressTextView.text = hospital?.address!
        networkPicker.selectRow(networks.index(of: (hospital?.network)!)!, inComponent: 0, animated: true)
        levelPicker.selectRow((hospital?.level)! - 1, inComponent: 0, animated: true)
        subspecialityField.text = hospital?.subspecialty
        latitudeField.text = "\((hospital?.location.coordinate.latitude)!)"
        longitudeField.text = "\((hospital?.location.coordinate.longitude)!)"
        switchboardView.text = hospital?.switchBoard!
        labourWardView.text = hospital?.labourWard!
        nicuView.text = hospital?.nicuNumber!
        nicuCoordinatorView.text = hospital?.nicuCoordinator
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case networkPicker:
            return networks.count
        default:
            return 3
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case networkPicker:
            return networksForHeaders[row]
        default:
            return "\(row + 1)"
        }
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        if checkFields() {
            formatter.dateFormat = "dd-MM-yy HH:mm"
            
            let hospitalData = [
            "address": addressTextView.text!,
            "labourWard": labourWardView.text!,
            "level": levelPicker.selectedRow(inComponent: 0) + 1,
            "location": ["latitude": Double(latitudeField.text!), "longitude": Double(longitudeField.text!)],
            "network": networks[networkPicker.selectedRow(inComponent: 0)],
            "nicu": nicuView.text!,
            "nicuCoordinator": nicuCoordinatorView.text,
            "subspecialty": subspecialityField.text!,
            "switchBoard": switchboardView.text!,
            "lastUpdated": formatter.string(from: date),
            "updatedBy": loggedInUserID!] as [String: Any]
            
            DataService.ds.createHospitalEntry(name: nameField.text!, hospitalData: hospitalData)
            
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
