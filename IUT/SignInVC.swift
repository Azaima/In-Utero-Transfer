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

    @IBOutlet weak var fullStack: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var registrationStack: UIStackView!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var rolePicker: UIPickerView!
    @IBOutlet weak var regionTable: UITableView!

    @IBOutlet weak var hospitalStack: UIStackView!
    @IBOutlet weak var hospitalTable: UITableView!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var extenderView: UIView!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var selectedRegionLabel: UILabel!
    @IBOutlet weak var selectedHospitalLabel: UILabel!
    
    
    var register = false
    var mainVC = MainVC()
    let roles = ["- Scroll to Select -", "Admin", "Neonatologist", "Obstetrician"]
    var userID: String?
    var hospital: String?
    var userData = [String:Any]()
    var successfulRegistration = false
    var selectedRegion = ""
    var hospitals = [""]
    var fields = [UITextField]()
    var listOfHospitalsForTable = [HospitalStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = country
        
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
        regionTable.delegate = self
        regionTable.dataSource = self
        
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
        scrollView.contentSize.height = fullStack.frame.height
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
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
        switch tableView {
        case hospitalTable:
            return listOfHospitalsForTable.count
        default:
            return regions.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hospitalCell")
        
        switch tableView {
        case hospitalTable:
            cell?.textLabel?.text = listOfHospitalsForTable[indexPath.row].name!
        default:
            cell?.textLabel?.text = regions.sorted(by: { (region1: (key: String, value: Any), region2: (key: String, value: Any)) -> Bool in
                region1.key < region2.key
            })[indexPath.row].key
            print(regions.sorted(by: { (region1: (key: String, value: Any), region2: (key: String, value: Any)) -> Bool in
                region1.key < region2.key
            })[indexPath.row].key)
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == regionTable {
            regionTable.isHidden = true
            selectedRegion = regions.sorted(by: { (region1: (key: String, value: Any), region2: (key: String, value: Any)) -> Bool in
                region1.key < region2.key
            })[indexPath.row].key
            if loggedInUserRegion == selectedRegion {
                
                listOfHospitalsForTable = hospitalsArray
                
                resetHospTable()
            }   else {
                
                listOfHospitalsForTable = [NO_HOSPITAL, EBS_Struct]
                
                DataService.ds.REF_HOSPITALS_BY_REGION.child(country).child(selectedRegion).observeSingleEvent(of: .value, with: { (hospitalListSnap) in
                    
                    if let hospitalList = hospitalListSnap.children.allObjects as? [FIRDataSnapshot] {
                        for hospital in hospitalList {
                            let hosp = HospitalStruct(hospitalSnap: hospital)
                            self.listOfHospitalsForTable.append(hosp)
                        }
                        
                        self.resetHospTable()
                    }
                })
            }
            
        }   else {
            hospitalTable.isHidden = true
            selectedHospitalLabel.text = listOfHospitalsForTable[indexPath.row].name
        }
    }
    
    func resetHospTable() {
        selectedRegionLabel.text = selectedRegion
        selectedHospitalLabel.text = ""
        if hospitalTable.indexPathForSelectedRow != nil {
            hospitalTable.deselectRow(at: hospitalTable.indexPathForSelectedRow!, animated: false)
            hospitalTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        self.hospitalTable.reloadData()
        self.hospitalStack.isHidden = false
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
                            
                            let role = self.rolePicker.selectedRow(inComponent: 0) == 0 ? "" : self.roles[self.rolePicker.selectedRow(inComponent: 0)]
                            self.userData = ["firstName": self.firstNameField.text!, "surname": self.surnameField.text!, "role": role,"hospital": self.hospital! ,"email":email, "newUser": "true", "country": country, "region": self.selectedRegion]
                            
                            DataService.ds.createFireBaseDBUser(uid: (user?.uid)!, region: self.selectedRegion, hospital: self.hospital! ,userData: self.userData)
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
        
        if regionTable.indexPathForSelectedRow == nil {
            errorLabel.text = "Please select a region"
            
            return false
        }
        
        if hospitalTable.indexPathForSelectedRow == nil {
            hospitalTable.backgroundColor = UIColor(red: 1, green: 205/255, blue: 210/255, alpha: 1)
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
        
        KeychainWrapper.standard.set(userID!, forKey: USER_UID)
        
        loggedInUserID = userID
        country = userData["country"] as! String
        loggedInUserRegion = userData["region"] as! String
        mainscreen?.prepareDataBase {
            loggedInUserData = self.userData
        }
        
        
    }
    
    func getUserData() {

        DataService.ds.REF_USERS.child(userID!).observe( .value, with: { (user) in
            self.userData = user.value as! [String:Any]
            
            self.updateMainScreen()
            _ = self.navigationController?.popViewController(animated: true)
        })
    }
    
    @IBAction func labelPressed(_ sender: UITapGestureRecognizer) {
        regionTable.isHidden = !regionTable.isHidden
    }
    
    @IBAction func hospitalLabelPressed(_ sender: Any) {
        hospitalTable.isHidden = !hospitalTable.isHidden
    }
}
