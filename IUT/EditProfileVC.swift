//
//  EditProfileVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 07/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit
import Firebase

class EditProfileVC: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var passwordStack: UIStackView!
    @IBOutlet weak var pageTitle: UINavigationItem!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var acknowledgeMessageStack: UIStackView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var changeEmailButton: UIButton!
    @IBOutlet weak var hospitalStack: UIStackView!
    
    @IBOutlet weak var changeHospitalButton: UIButton!
    @IBOutlet weak var changePasswordStack: UIStackView!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var changeEmailStack: UIStackView!
    @IBOutlet weak var hospitalTable: UITableView!
    
    var fields = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fields = [passwordField, newPasswordField,confirmPasswordField,emailField]
        for field in fields {
            field.delegate = self
        }
        hospitalTable.delegate = self
        hospitalTable.dataSource = self
        
        removeBackButton(self, title: nil)
        setupFields()
        passwordField.becomeFirstResponder()
        
    }

    // MARK: Setting up Fields
    
    func setupFields () {
        pageTitle.title = "\((loggedInUserData?["firstName"])!) \((loggedInUserData?["surname"])!) Profile"
        
        emailField.text = "\((loggedInUserData?["email"])!)"
        
        hospitalTable.selectRow(at: IndexPath (row: hospitalsArray.index(where: { (HospitalStruct) -> Bool in
            return HospitalStruct.name == loggedHospitalName
        })!, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.none)
        
        hospitalTable.scrollToRow(at: IndexPath (row: hospitalsArray.index(where: { (HospitalStruct) -> Bool in
            return HospitalStruct.name == loggedHospitalName
        })!, section: 0), at: UITableViewScrollPosition.none, animated: true)
    }
    
    // MARK: PickerView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hospitalsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hospitalCellEditProfile")
        cell?.textLabel?.text = hospitalsArray[indexPath.row].name
        
        return cell!
    }
    
    
    
    // MARK: Editing profile fields
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        switch textField {
        case passwordField:
            confirmPasswordPressed(passwordField)
            
        case emailField:
            changeEmailPressed(changeEmailButton)
            
            
        default:
            changePasswordPressed(changePasswordButton)
        }

        return true
    }
    
    @IBAction func confirmPasswordPressed(_ sender: Any) {
        if passwordField.text != "" && passwordField.text != nil {
            FIRAuth.auth()?.signIn(withEmail: loggedInUserData?["email"] as! String, password: passwordField.text!, completion: { (user, error) in
                
                if error != nil {
                    
                    self.message(text: "\((error?.localizedDescription)!)", alert: true)
                }   else {
                    
                    self.passwordStack.isHidden = true
                    self.changeEmailStack.isHidden = false
                    self.hospitalStack.isHidden = false
                    self.changePasswordStack.isHidden = false
                }
            })
            
        }
    }
    
    @IBAction func changeEmailPressed(_ sender: Any) {
        
        if emailField.isUserInteractionEnabled {
            emailField.isUserInteractionEnabled = false
            changeButton(button: changeEmailButton, title: "Change email", confirm: false)
            
            if emailField.text != "" && emailField.text != nil && emailField.text != loggedInUserData?["email"] as? String {
                FIRAuth.auth()?.currentUser?.updateEmail(emailField.text!, completion: { (error) in
                    if error != nil {
                        self.message(text: "\((error?.localizedDescription)!)", alert: true)
                    }   else {
                        self.message(text: "Email successfully changed", alert: false)
                        loggedInUserData?["email"] = self.emailField.text!
                        DataService.ds.REF_USERS.child(loggedInUserID!).updateChildValues(["email": self.emailField.text!])
                    }
                })
            }
            
        }   else {
            emailField.isUserInteractionEnabled = true
            emailField.becomeFirstResponder()
            changeButton(button: changeEmailButton, title: "Confirm", confirm: true)
            
            
        }
    }
    
    func changeButton(button: UIButton, title: String, confirm: Bool){
        
        if confirm {
            button.setTitle("Confirm", for: .normal)
            button.backgroundColor = UIColor(red: 81/255, green: 164/255, blue: 1, alpha: 1)
            button.setTitleColor(UIColor.white, for: .normal)
        }   else {
            button.setTitle(title, for: .normal)
            button.backgroundColor = .white
            button.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), for: .normal)
        }
    }
    
    @IBAction func changeHospitalPressed(_ sender: Any) {
        if !hospitalTable.isUserInteractionEnabled {
            
            message(text: "Changing your link hospital will reset your privilages till your account has been reviewed by the new hospital's admin team.\nWould you like to proceed?", alert: true)
            acknowledgeMessageStack.isHidden = false
        }   else {
            
            hospitalTable.isUserInteractionEnabled = false
            changeButton(button: changeHospitalButton, title: "Change Hospital", confirm: false)
            
            if hospitalTable.indexPathForSelectedRow != nil {
                loggedInUserHospital = hospitalsArray[(hospitalTable.indexPathForSelectedRow?.row)!]
            }
                
            DataService.ds.changeUserHospital(oldHospital: loggedHospitalName!, newHospital: (loggedInUserHospital?.name!)!)
            
            loggedHospitalName = loggedInUserHospital?.name!
            loggedInUserData?["hospital"] = loggedInUserHospital?.name!
            
            
        }
    }

    func message(text: String, alert: Bool) {
        messageLabel.textColor = alert ? UIColor.red : UIColor.black
        messageLabel.text = text
    }
    @IBAction func changePasswordPressed(_ sender: Any) {
        
        if !newPasswordField.isUserInteractionEnabled {
            newPasswordField.isUserInteractionEnabled = true
            confirmPasswordField.isUserInteractionEnabled = true
            newPasswordField.becomeFirstResponder()
            changeButton(button: changePasswordButton, title: "Confirm", confirm: true)
        }   else {
            
            if newPasswordField.text != nil && (newPasswordField.text?.characters.count)! > 5 && newPasswordField.text == confirmPasswordField.text {
                
                FIRAuth.auth()?.currentUser?.updatePassword(newPasswordField.text!, completion: { (error) in
                    if error != nil {
                        self.message(text: "\((error?.localizedDescription)!)", alert: true)
                    }   else {
                        self.message(text: "Password successfully changed", alert: false)
                    }

                })
            }   else if newPasswordField.text != nil && passwordField.text!.characters.count <= 5 {
                
                message(text: "Password has to be 6 characters or more", alert: true)
                
            }   else if newPasswordField.text != confirmPasswordField.text {
                message(text: "New password and Confirm Password are not matching", alert: true)
            }
            
            newPasswordField.isUserInteractionEnabled = false
            confirmPasswordField.isUserInteractionEnabled = false
            newPasswordField.resignFirstResponder()
            confirmPasswordField.resignFirstResponder()
            changeButton(button: changePasswordButton, title: "Change Password", confirm: false)
            
        }
    }
    
    @IBAction func acknowledgeButtonsPressed(_ sender: UIButton) {
        
        acknowledgeMessageStack.isHidden = true
        
        if sender.tag == 1 {
            hospitalTable.isUserInteractionEnabled = true
            message(text: "Please select the new hospital", alert: false)
            changeButton(button: changeHospitalButton, title: "Confirm", confirm: true)
        }
    }
    
}
