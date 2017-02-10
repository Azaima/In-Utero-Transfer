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
    var updatingCotStatus = false
    var viewOnlyMode = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fullStack: UIStackView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var hospitalNameStack: UIStackView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var networkPicker: UIPickerView!
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
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var fields = [UITextField]()
    var textViews = [UITextView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        networkPicker.delegate = self
        networkPicker.dataSource = self
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
        networkPicker.isUserInteractionEnabled = false
        levelPicker.isUserInteractionEnabled = false
        subspecialityView.isUserInteractionEnabled = false
        geolocationStack.isHidden = true
        
        
        
        for textview in textViews {
            textview.isEditable = false
            textview.dataDetectorTypes = .phoneNumber
        }
    }
    
    func setupFields() {
        hospitalNameStack.isHidden = true
        nameField.text = hospital?.name!
        addressTextView.text = hospital?.address!
        networkPicker.selectRow(networks.index(of: (hospital?.network)!)!, inComponent: 0, animated: true)
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
                    "network": networks[networkPicker.selectedRow(inComponent: 0)],
                    "nicu": nicuView.text!,
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
