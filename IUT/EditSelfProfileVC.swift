//
//  EditSelfProfileVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 13/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import UIKit
import Firebase

class EditSelfProfileVC: UIViewController, UITextFieldDelegate, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    let alertMessage = UIAlertController(title: nil, message: "", preferredStyle: UIAlertControllerStyle.alert)
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var acitivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var rolePicker: UIPickerView!
    @IBOutlet weak var hospitalSearchField: UISearchBar!
    @IBOutlet weak var hospitalPicker: UIPickerView!
    @IBOutlet weak var oldPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    var fields = [UIView]()
    let roles = ["Admin", "Midwife" , "Nurse", "Obstetrician", "Neonatologist"]
    var hospitalSearchList = [HospitalStructure]() {
        didSet {
            hospitalPicker.reloadComponent(0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        removeBackButton(self, title: nil)
        alertMessage.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        fields = [firstnameField, surnameField, emailField, rolePicker, hospitalSearchField, hospitalPicker, oldPasswordField, newPasswordField, confirmPasswordField]
        
        fields.forEach { (field) in
            if field is UITextField {
                (field as! UITextField).delegate = self
            }   else if field is UISearchBar {
                (field as! UISearchBar).delegate = self
            }   else {
                (field as! UIPickerView).delegate = self
                (field as! UIPickerView).dataSource = self
            }
        }
        setData()
        
    }

    
    
    func setData(){
        firstnameField.text = userData["firstName"] as? String
        surnameField.text = userData["surname"] as? String
        emailField.text = userData["email"] as? String
        rolePicker.selectRow(roles.index(of: (userData["role"]! as! String))!, inComponent: 0, animated: true)
        hospitalSearchField.text = userData["hospital"] as? String
        hospitalSearchList = [userData["hospitalStructure"] as! HospitalStructure]
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text?.lowercased() {
            if searchText != "" {
                hospitalSearchList = hospitals.filter({ (hospital) -> Bool in
                    return hospital.name.lowercased().contains(searchText)
                })
            }   else {
                hospitalSearchList = []
            }
        }   else {
            hospitalSearchList = []
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == rolePicker {
            return roles.count
        }   else {
            return hospitalSearchList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == rolePicker {
            return roles[row]
        }   else {
            return hospitalSearchList[row].name
        }
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        if oldPasswordField.text != "" || newPasswordField.text != "" {
            
            if let newPassword = newPasswordField.text, let confirmPassword = confirmPasswordField.text, let oldPassword = oldPasswordField.text {
                if oldPassword == sessionData?.password && newPassword == confirmPassword {
                    FIRAuth.auth()?.signIn(withEmail: sessionData!.email, password: oldPassword, completion: { (user, error) in
                        if user != nil && error == nil {
                            self.startIndicator()
                            FIRAuth.auth()?.currentUser?.updatePassword(newPassword, completion: { (error) in
                                self.stopIndicator()
                                if error == nil {
                                    self.alertMessage.message = "Password successfully reset"
                                    self.present(self.alertMessage, animated: true, completion: nil)
                                    self.oldPasswordField.text = ""
                                    self.newPasswordField.text = ""
                                    self.confirmPasswordField.text = ""
                                    
                                }   else {
                                    self.alertMessage.message = "An error occured while attempting to change your password. \(error!.localizedDescription)"
                                    self.present(self.alertMessage, animated: true, completion: nil)
                                }
                            })
                        }   else {
                            self.alertMessage.message = "An error occured while authenticating you credentials. \(error!.localizedDescription)"
                            self.alertMessage.present(self.alertMessage, animated: true, completion: nil)
                        }
                    })
                }
            }   else {
                alertMessage.message = "To change your password, all password fields must be filled"
                self.alertMessage.present(self.alertMessage, animated: true, completion: nil)
                return
            }
        }   else if emailField.text != userData["email"] as? String && emailField.text != "" && emailField.text != nil {
            
            FIRAuth.auth()?.signIn(withEmail: sessionData!.email, password: sessionData!.password, completion: { (user, error) in
                if user != nil && error == nil {
                    self.startIndicator()
                    FIRAuth.auth()?.currentUser?.updateEmail(self.emailField.text!, completion: { (error) in
                        if error == nil {
                            sessionData?.email = self.emailField.text!
                            DB_BASE.child("users").child(sessionData!.uid).updateChildValues(["email":self.emailField.text!])
                            COTFINDER2_REF.child("usersByHospital").child(userData["hospitalKey"]! as! String).child(sessionData!.uid).child("details").updateChildValues(["email": self.emailField.text!])
                            self.stopIndicator()
                            self.alertMessage.message = "Email successfully updated"
                            self.present(self.alertMessage, animated: true, completion: nil)
                        }
                    })
                }   else {
                    self.alertMessage.message = "An error occured while authenticating you credentials"
                    self.alertMessage.present(self.alertMessage, animated: true, completion: nil)
                }
            })
        }   else if (firstnameField.text != userData["firstName"]! as? String || surnameField.text != userData["surname"]! as? String) && (firstnameField.text != nil && firstnameField.text != nil && surnameField.text != "" && surnameField.text != nil) {
            DB_BASE.child("users").child(sessionData!.uid).updateChildValues(["firstName": self.firstnameField.text!, "surname": self.surnameField.text!])
            COTFINDER2_REF.child("usersByHospital").child(userData["hospitalKey"]! as! String).child(sessionData!.uid).child("details").updateChildValues(["firstName": self.firstnameField.text!, "surname": self.surnameField.text!])
        } else if !hospitalSearchList.isEmpty && hospitalSearchList[hospitalPicker.selectedRow(inComponent: 0)].key != userData["hospitalKey"]! as? String {
            let selectedHospital = hospitalSearchList[hospitalPicker.selectedRow(inComponent: 0)]
            let oldHospital = userData["hospitalStructure"]! as!HospitalStructure
            
            userData["hospital"] = selectedHospital.name
            userData["hospitalKey"] = selectedHospital.key
            userData["hospitalStructure"] = selectedHospital
            
            DB_BASE.child("users").child(sessionData!.uid).updateChildValues(["hospital": selectedHospital.name, "hospitalKey": selectedHospital.key])
           
            COTFINDER2_REF.child("usersByHospital").child(oldHospital.key).child(sessionData!.uid).removeValue()
            COTFINDER2_REF.child("usersByHospital").child(selectedHospital.key).child(sessionData!.uid).child("details").updateChildValues(["firstName": userData["firstName"]! as! String, "surname": userData["surname"]! as! String, "email": sessionData!.email])
            
            if let index = hospitals.index(where: { (hospital) -> Bool in
                return hospital.key == oldHospital.key
            }) {
                hospitals[index].markView.image = homePage?.setImageForAnnotation(for: oldHospital.key, level: oldHospital.level)
            }
            
            alertMessage.message = "Hospital successfully updated.\nPlease note that all your entitlements have been reset. Your file will need to be reviewed by your admin team to set your new entitlements."
            present(alertMessage, animated: true, completion: nil)
            
        }   else if roles[rolePicker.selectedRow(inComponent: 0)] != userData["role"]! as! String {
            DB_BASE.child("users").child(sessionData!.uid).updateChildValues(["role": roles[rolePicker.selectedRow(inComponent: 0)]])
        }
        
    }
    
    func startIndicator(){
        indicatorView.isHidden = false
        acitivityIndicator.startAnimating()
    }
    
    func stopIndicator(){
        indicatorView.isHidden = true
        acitivityIndicator.stopAnimating()
    }
}
