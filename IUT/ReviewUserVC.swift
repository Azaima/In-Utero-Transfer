//
//  ReviewUserVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 05/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit

class ReviewUserVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var wholeStack: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var rolePicker: UIPickerView!
    @IBOutlet weak var superUserStack: UIStackView!
    @IBOutlet weak var superSwitch: UISwitch!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var administrativeSwitch: UISwitch!
    
    @IBOutlet weak var feedbackSwitch: UISwitch!
    
    @IBOutlet weak var statusSwitch: UISwitch!
    @IBOutlet weak var superUserLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var entitlementsStack: UIStackView!
    
    let roles = ["", "Admin", "Neonatologist", "Obstetrician"]
    
    var switches = [UISwitch]()
    var newUser = false
    var selectedUser = [String:Any]()
    var userDict = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserData {
            
        
            self.scrollView.contentSize.width = self.view.frame.width - 40
            removeBackButton(self, title: nil)
            self.rolePicker.delegate = self
            self.rolePicker.dataSource = self
            
            self.switches = [self.administrativeSwitch, self.feedbackSwitch,self.statusSwitch]
            self.setupData()
            if self.userDict["userID"] as! String == loggedInUserID!{
                self.disablePage("You are not allowed to\nedit your own profile")
            } else {
            
                if self.userDict["superUser"] as? String == "true" {
                    if loggedInUserData?["superUser"] as? String != "true" {
                        self.disablePage("This user profile can ONLY\nbe modified by a Super User")
                    }
                } else {
                    if loggedInUserData?["superUser"] as? String != "true" {
                        self.superUserStack.isHidden = true
                    }
                }
            }
        }
    }
    
    func getUserData(completed: @escaping DownloadComplete) {
        DataService.ds.REF_USERS.child(selectedUser["userID"] as! String).observeSingleEvent(of: .value, with: { (userSnapshot) in
            if let dict = userSnapshot.value as? [String: Any] {
                self.userDict = dict
                self.userDict["userID"] = userSnapshot.key
                print(self.userDict)
                
                self.newUser = self.selectedUser["newUser"] as? String == "true"
            }
            completed()
        })
        
    }
    
    func disablePage(_ message: String) {
        superSwitch.isHidden = true
        entitlementsStack.isHidden = true
        superUserLabel.textAlignment = .center
        superUserLabel.textColor = .red
        superUserLabel.text = message
        saveButton.isEnabled = false
        rolePicker.isUserInteractionEnabled = false
    }
    
    func setupData() {
        nameLabel.text = "\((userDict["firstName"] as! String)) \((userDict["surname"] as! String))"
        emailLabel.text = "\(userDict["email"] as! String)"
        rolePicker.selectRow(roles.index(of: userDict["role"] as! String)!, inComponent: 0, animated: true)
        
        superSwitch.isOn = userDict["superUser"] as? String == "true"
        administrativeSwitch.isOn = userDict["adminRights"] as? String == "true" || userDict["superUser"] as? String == "true"
        feedbackSwitch.isOn = userDict["feedbackRights"] as? String == "true" || userDict["superUser"] as? String == "true"
        statusSwitch.isOn = userDict["statusRights"] as? String == "true" || userDict["superUser"] as? String == "true"
        
        
    }

    @IBAction func superSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            for swtch in switches {
                swtch.isOn = true
            }
        }
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        var updateDict = [String:Any]()
        updateDict["role"] = roles[rolePicker.selectedRow(inComponent: 0)]
        
        updateDict["superUser"] = superSwitch.isOn ? "true" : nil
        
        updateDict["adminRights"] = administrativeSwitch.isOn ? "true" : nil
        updateDict["feedbackRights"] = feedbackSwitch.isOn ? "true" : nil
        updateDict["statusRights"] = statusSwitch.isOn ? "true" : nil
        
        formatter.dateFormat = "dd-MM-yy HH:mm"
        updateDict["entitlementsReviewed"] = ["reviewerID": loggedInUserID, "reviewDate": formatter.string(from: date)]
        
        DataService.ds.updateUserProfile(uid: userDict["userID"] as! String, userData: updateDict, wasNew: newUser)
        _ = navigationController?.popViewController(animated: true)
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

}
