//
//  EditHospitalDetailsVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 14/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import UIKit

class EditHospitalDetailsVC: UIViewController {

    
    
    @IBOutlet weak var pageTitle: UINavigationItem!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var levelField: UITextField!
    @IBOutlet weak var regionField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var networkField: UITextField!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var subspecialtyField: UITextView!
    @IBOutlet weak var labourWardField: UITextField!
    @IBOutlet weak var switchBoardField: UITextField!
    @IBOutlet weak var nicuField: UITextField!
    @IBOutlet weak var nicuCoordField: UITextField!
    @IBOutlet weak var addressField: UITextView!
    
    let alertMessage = UIAlertController(title: nil, message: "", preferredStyle: UIAlertControllerStyle.alert)
    
    var hospital: HospitalStructure? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeBackButton(self, title: nil)
        alertMessage.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        if hospital != nil {
            nameField.text = hospital!.name
            levelField.text = "\(hospital!.level!)"
            addressField.text = hospital!.address
            regionField.text = hospital!.region
            countryField.text = hospital!.country
            networkField.text = hospital!.network
            latitudeField.text = "\(hospital!.location.latitude)"
            longitudeField.text = "\(hospital!.location.longitude)"
            switchBoardField.text = hospital!.switchBoard
            labourWardField.text = hospital!.labourWard
            nicuField.text = hospital!.nicu
            nicuCoordField.text = hospital!.nicuCoordinator
            subspecialtyField.text = hospital!.subspecialty
            
        }
    }

    @IBAction func savePressed(_ sender: Any) {
        var hospitalDetails = [String:Any]()
        
        if let name = nameField.text {
            hospitalDetails["name"] = name
        }   else {
            alert()
            return
        }
        
        if let levelText = levelField.text {
            if let level = Int(levelText){
                hospitalDetails["level"] = level
            }else {
                alert()
                return
            }
        }else {
            alert()
            return
        }
        
        if let address = addressField.text {
            hospitalDetails["address"] = address
        } else {
            alert()
            return
        }
        
        if let network = networkField.text {
            hospitalDetails["network"] = network
        }   else {
            hospitalDetails["network"] = ""
        }
        
        if let region = regionField.text {
            hospitalDetails["region"] = region
        }   else {
            alert()
            return
        }
        
        if let country = countryField.text {
            hospitalDetails["country"] = country
        }   else {
            alert()
            return
        }
        
        if let switchBoard = switchBoardField.text {
            hospitalDetails["switchBoard"] = switchBoard
        }   else {
            alert()
            return
        }
        
        if let labourWard = labourWardField.text {
            hospitalDetails["labourWard"] = labourWard
        }   else {
            alert()
            return
        }
        
        if let nicu = nicuField.text {
            hospitalDetails["nicu"] = nicu
        }   else {
            alert()
            return
        }
        
        if let nicuCoordinator = nicuCoordField.text {
            hospitalDetails["nicuCoordinator"] = nicuCoordinator
        }   else {
            hospitalDetails["nicuCoordinator"] = ""
        }
            
        if let subspecialty = subspecialtyField.text {
            hospitalDetails["subspecialty"] = subspecialty
        }   else {
            hospitalDetails["subspecialty"] = ""
        }
        
        if let latitudeText = latitudeField.text, let longitudeText = longitudeField.text {
            
            if let latitude = Float(latitudeText), let longitude = Float(longitudeText){
                hospitalDetails["location"] = [
                    "latitude": latitude,
                    "longitude": longitude
                ]
            }   else {
                alert()
                return
            }
        }   else {
            alert()
            return
        }
        
            
        COTFINDER2_REF.child("hospitals").child(hospital!.key).updateChildValues(hospitalDetails)
        navigationController?.popViewController(animated: true)
    }
    
    func alert(){
        alertMessage.message = "Please ensure all mandatory data are filled"
        present(alertMessage, animated: true, completion: nil)
    }
    
}
