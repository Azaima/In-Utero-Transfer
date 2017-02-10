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

class SignInVC: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var registrationStack: UIStackView!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var rolePicker: UIPickerView!
//    @IBOutlet weak var hospitalPicker: UIPickerView!
    @IBOutlet weak var hospitalTable: UITableView!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var extenderView: UIView!
    
    
    
    var register = false
    var mainVC = MainVC()
    let roles = ["", "Admin", "Neonatologist", "Obstetrician"]
    var userID: String?
    var hospital: String?
    var userData = [String:Any]()
    var successfulRegistration = false
    
    var hospitals = [""]
    var fields = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize.height = self.view.frame.height
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        fields = [emailField,passwordField, confirmPasswordField, firstNameField, surnameField]
        for field in fields {
            field.delegate = self
        }
        removeBackButton(self, title: "Cancel")
        setupView()
        emailField.becomeFirstResponder()
        rolePicker.delegate = self
        rolePicker.dataSource = self
        hospitalTable.delegate = self
        hospitalTable.dataSource = self
        
    }

    
    
    func setupView() {
        forgotPasswordButton.isHidden = register
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
        return roles.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
            return roles[row]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hospitalsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hospitalCell")
        cell?.textLabel?.text = hospitalsArray[indexPath.row].name!
        
        return cell!
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
                    
                    self.userID = user?.uid
                    self.getUserData ()
                })
            }
        case true:
            if successfulRegistration {
                _ = self.navigationController?.popViewController(animated: true)
            }   else {
                if checkFields() {
                    if let email = emailField.text, let password = passwordField.text {
                        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                            guard error == nil else {
                                self.errorLabel.text = (error?.localizedDescription)!
                                return
                            }
                            self.userID = user?.uid
                            
                            if self.hospitalTable.indexPathForSelectedRow != nil {
                                self.hospital = hospitalsArray[(self.hospitalTable.indexPathForSelectedRow?.row)!].name
                            } else {
                                self.hospital = "(None)"
                            }
                            self.userData = ["firstName": self.firstNameField.text!, "surname": self.surnameField.text!, "role": self.roles[self.rolePicker.selectedRow(inComponent: 0)],"hospital": self.hospital! ,"email":email, "newUser": "true"]
                            
                            DataService.ds.createFireBaseDBUser(uid: (user?.uid)!, hospital: self.hospital! ,userData: self.userData)
                            self.updateMainScreen()
                            self.signInButton.setTitle("Done", for: .normal)
                            self.signInButton.backgroundColor = UIColor(red: 0, green: 230/255, blue: 118/255, alpha: 1)

                            for field in self.fields {
                                field.isUserInteractionEnabled = false
                            }
                            self.rolePicker.isUserInteractionEnabled = false
                            self.hospitalTable.isUserInteractionEnabled = false
                            
                            self.errorLabel.text = "Welcome to IUT App.\nYour registration was successfully completed.\nYour local admin team will review your registration and manage your App entitlements."
                            self.successfulRegistration = true
                        })
                    }
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
        if (passwordField.text?.characters.count)! < 6 {
            passwordField.backgroundColor = UIColor(red: 1, green: 205/255, blue: 210/255, alpha: 1)
            errorLabel.text = "Password must have at least 6 characters"
            return false
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
    
    func successfullySignedIn() {
        
        if userData.isEmpty {
            getUserData()
        }   else {
            self.updateMainScreen()
            
        }
        
    }
    
    func updateMainScreen() {
        mainscreen?.toggleSignInButton(signedIn: true, userData: userData)
        
        KeychainWrapper.standard.set(userID!, forKey: USER_UID)
        
        
        loggedInUserID = userID
        loggedInUserData = userData
        
    }
    
    func getUserData() {

        DataService.ds.REF_USERS.child(userID!).observeSingleEvent(of: .value, with: { (user) in
            self.userData = user.value as! [String:Any]
            
            self.updateMainScreen()
            _ = self.navigationController?.popViewController(animated: true)
        })
    }
}
