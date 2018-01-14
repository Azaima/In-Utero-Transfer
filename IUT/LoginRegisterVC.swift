//
//  LoginRegisterVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 07/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import UIKit
import Firebase

class LoginRegisterVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var registerView: UIScrollView!
    
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    
    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var registerEmailField: UITextField!
    @IBOutlet weak var rolePicker: UIPickerView!
    @IBOutlet weak var hospitalSearchField: UISearchBar!
    @IBOutlet weak var hospitalPicker: UIPickerView!
    @IBOutlet weak var registerPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    let alertMessage = UIAlertController(title: nil, message: "", preferredStyle: UIAlertControllerStyle.alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertMessage.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        rolePicker.dataSource = self
        hospitalPicker.dataSource = self
        rolePicker.delegate = self
        hospitalPicker.delegate = self
        hospitalSearchField.delegate = self
        
        hospitalPicker.selectRow(0, inComponent: 0, animated: false)
        
    }

    @IBAction func loginRegisterSelected(_ sender: UISegmentedControl) {
        loginView.isHidden = sender.selectedSegmentIndex == 1
        registerView.isHidden = sender.selectedSegmentIndex == 0
    }
    
    @IBAction func forgottenPasswordPressed(_ sender: Any) {
        if loginEmailField.text == nil || loginEmailField.text == "" {
            alertMessage.message = "Please enter your registered email in the email field."
            present(alertMessage, animated: true, completion: nil)
        }   else {
            let email = loginEmailField.text!
            FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error: Error?) in
                if error == nil {
                    self.alertMessage.message = "A password reset email has been sent to \(email). Please follow the link in the email to reset your password."
                    self.present(self.alertMessage, animated: true, completion: nil)
                }   else {
                    self.alertMessage.message = "An error occured while attempting to reset your password.\n\((error?.localizedDescription)!)"
                    self.present(self.alertMessage, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        if loginEmailField.text != nil && loginEmailField.text != "" && loginPasswordField.text != nil && loginPasswordField.text != "" {
            
            let email = loginEmailField.text!
            let password = loginPasswordField.text!
            
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (returnedUser, error) in
                if  error != nil {
                    self.alertMessage.message = "An error occured while attempting to log in.\n\((error?.localizedDescription)!)"
                    self.present(self.alertMessage, animated: true, completion: nil)
                }   else {
                    if let user = returnedUser {
                        let sessionInfo = SessionData(context: context)
                        sessionInfo.email = email
                        sessionInfo.password = password
                        sessionInfo.uid = user.uid
                        sessionInfo.lastLogin = Date () as NSDate
                        sessionData = sessionInfo
                        ad.saveContext()
                        
                        homePage!.getUserData()
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
        }
    }
    
//    Setup picker views
    let roles = ["Admin", "Midwife" , "Nurse", "Obstetrician", "Neonatologist"]
    
    var hospitalSearchList = [HospitalStructure]()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == rolePicker {
            return roles.count
        }   else {
            if hospitalSearchField.text != nil && hospitalSearchField.text != "" {
                return hospitalSearchList.count
            }   else {
                return hospitals.count
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == rolePicker {
            return roles[row]
        }   else {
            
            if hospitalSearchField.text != nil && hospitalSearchField.text != "" {
                return hospitalSearchList[row].name
            }   else {
                return hospitals[row].name
            }
            
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if hospitalSearchField.text != nil && hospitalSearchField.text != "" {
            hospitalSearchList = hospitals.filter({ (hospital) -> Bool in
                return hospital.name.lowercased().contains((hospitalSearchField.text)!.lowercased())
            })
        }
        
        hospitalPicker.reloadAllComponents()
        if !(hospitalSearchField.text != nil && hospitalSearchField.text != "" && hospitalSearchList.isEmpty){
                hospitalPicker.selectRow(0, inComponent: 0, animated: false)
        }   else {
            hospitalPicker.selectRow(-1, inComponent: 0, animated: false)
        }
        
    }
 
//    Registration
    @IBAction func registerPressed(_ sender: Any) {
        if (firstnameField.text == nil || firstnameField.text == ""){
            alertMessage.message = "First name field cannot be empty."
            present(alertMessage, animated: true, completion: nil)
        }   else if (surnameField.text == nil || surnameField.text == ""){
            alertMessage.message = "Surname field cannot be empty."
            present(alertMessage, animated: true, completion: nil)
        }   else if (registerEmailField.text == nil || registerEmailField.text == ""){
            alertMessage.message = "Email field cannot be empty."
            present(alertMessage, animated: true, completion: nil)
        }   else if (hospitalSearchField.text != nil && hospitalSearchField.text != "" && hospitalSearchList.isEmpty){
            alertMessage.message = "Please ensure that you have appropriately selected a link hospital."
            present(alertMessage, animated: true, completion: nil)
        }   else if (registerPasswordField.text == nil || registerPasswordField.text == "" || registerPasswordField.text != confirmPasswordField.text){
            alertMessage.message = "Incorrect password entered."
            present(alertMessage, animated: true, completion: nil)
        }   else    {

            var selectedHospital: HospitalStructure
            
            if hospitalSearchField.text != nil && hospitalSearchField.text != "" {
                selectedHospital = hospitalSearchList[hospitalPicker.selectedRow(inComponent: 0)]
                
            }   else {
                selectedHospital = hospitals[hospitalPicker.selectedRow(inComponent: 0)]
                
            }
            
            var profile = [
                "firstName": firstnameField.text!,
                "surname": surnameField.text!,
                "email": registerEmailField.text!,
                "role": roles[rolePicker.selectedRow(inComponent: 0)],
                "country": selectedHospital.country,
                "region": selectedHospital.region,
                "hospital": selectedHospital.name,
                "hospitalKey": selectedHospital.key
            ]
            
            FIRAuth.auth()?.createUser(withEmail: (registerEmailField.text)!, password: (registerPasswordField.text)!, completion: { (returnedUser, error) in
                
                if error == nil {
                    if let user = returnedUser {
                        let sessionInfo = SessionData(context: context)
                        sessionInfo.email = user.email!
                        sessionInfo.password = (self.registerPasswordField.text)!
                        sessionInfo.uid = user.uid
                        sessionInfo.lastLogin = Date() as NSDate
                        
                        sessionData = sessionInfo
                        ad.saveContext()
                        
                        userData = profile as [String : Any]
                        
                        
                        
                        
                        homePage?.setGreeting(visible: true)
                        
                        COTFINDER2_REF.child("usersByHospital").child(profile["hospitalKey"]!!).child(user.uid).updateChildValues(["details" : ["firstName": profile["firstName"]!, "surname": profile["surname"]!, "email": profile["email"]!]])
                        
                        DB_BASE.child("users").child(user.uid).updateChildValues(profile)
                        
                        if let index = hospitals.index(where: { (hospital: HospitalStructure) -> Bool in
                            return hospital.key == userData["hospitalKey"] as! String
                        })  {
                            userData["hospitalStructure"] = hospitals[index]
                        }
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
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
