//
//  SignInVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 31/01/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var registrationStack: UIStackView!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var rolePicker: UIPickerView!
    @IBOutlet weak var hospitalPicker: UIPickerView!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var register = false
    let roles = ["", "Admin", "Neonatologist", "Obstetrician"]
    var hospitals = [""]
    var fields = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fields = [emailField,passwordField, confirmPasswordField, firstNameField, surnameField]
        for field in fields {
            field.delegate = self
        }
        removeBackButton(self, title: "Cancel")
        setupView()
        emailField.becomeFirstResponder()
        rolePicker.delegate = self
        rolePicker.dataSource = self
        hospitalPicker.delegate = self
        hospitalPicker.dataSource = self
    }

    func setupView() {
        if register {
            
            registrationStack.isHidden = false
            signInButton.setTitle("Register and Sign In", for: .normal)
            signInButton.backgroundColor = UIColor(red: 1, green: 143/255, blue: 0, alpha: 1)
            
        }   else {
            
            registrationStack.isHidden = true
            signInButton.setTitle("Sign In", for: .normal)
            signInButton.backgroundColor = UIColor(red: 0, green: 230/255, blue: 118/255, alpha: 1)
            
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == rolePicker {
            return roles.count
        }   else {
            return hospitalsArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == rolePicker {
            return roles[row]
        }   else {
            return hospitalsArray[row].name
        }
    }
    
    @IBAction func signInPressed(_ sender: UIButton) {
        errorLabel.text = ""
        switch register {
        case false:
            guard emailField.text != "" && passwordField.text != "" else {
                return
            }
            if let email = emailField.text, let password = passwordField.text {
                FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                    guard error == nil else {
                        self.errorLabel.text = (error?.localizedDescription)!
                        return
                    }
                    
                    print("Ahmed: Successfully signed in")
                })
            }
        case true:
            if checkFields() {
                if let email = emailField.text, let password = passwordField.text {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        guard error == nil else {
                            self.errorLabel.text = (error?.localizedDescription)!
                            return
                        }
                        
                        let userData = ["firstName": self.firstNameField.text!, "surname": self.surnameField.text!, "role": self.roles[self.rolePicker.selectedRow(inComponent: 0)], "hospital": hospitalsArray[self.hospitalPicker.selectedRow(inComponent: 0)].name]
                        
                        self.completeSignin(id: (user?.uid)!, userData: userData as! [String : String])
                        
                    })
                }
            }
            
        }
    }
    
    func checkFields() -> Bool {
        
        for field in fields {
            if field.text == "" {
                field.backgroundColor = UIColor(red: 1, green: 205/255, blue: 210/255, alpha: 1)
                field.placeholder = "Mandatory Field"
                return false
            }
        }
        
        if passwordField.text != confirmPasswordField.text {
            confirmPasswordField.text = ""
            confirmPasswordField.backgroundColor = UIColor(red: 1, green: 205/255, blue: 210/255, alpha: 1)
            confirmPasswordField.placeholder = "Password not Matching"
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        _ = checkFields()
        return true
    }
    
    func completeSignin(id: String, userData: [String:String]) {
        DataService.ds.createFireBaseDBUser(uid: id, userData: userData)
        KeychainWrapper.standard.set(id, forKey: USER_UID)
        
        
    }
}