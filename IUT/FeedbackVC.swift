//
//  FeedbackVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 04/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit

class FeedbackVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var feedbackText: UITextView!
    
    var hospitalToFeedback = ""
    var messageFromTransfer = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !messageFromTransfer {
            hospitalToFeedback = loggedInUserData?["hospital"] as! String
        }
        removeBackButton(self, title: nil)
        titleField.becomeFirstResponder()
        
        titleField.delegate = self
        feedbackText.delegate = self
    }

    @IBAction func submitPressed(_ sender: UIBarButtonItem) {
        resignFirstResponder()
        if checkFields() {
            
            
            let hospital = messageFromTransfer ? (currentHospital?.name)! : loggedHospitalName!
            
            
            DataService.ds.createFeedbackMessage(hospital: (hospitalToFeedback), userID: loggedInUserID!, title: titleField.text!, body: feedbackText.text!, hospitalFrom: hospital)
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func checkFields() -> Bool {
        if titleField.text == "" {
            titleField.backgroundColor = UIColor(red: 1, green: 205/255, blue: 210/255, alpha: 1)
            titleField.placeholder = "Title cannot be Empty!"
            return false
        }
        
        if feedbackText.text == "" {
            feedbackText.backgroundColor = UIColor(red: 1, green: 205/255, blue: 210/255, alpha: 1)
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        turnWhite(sender: textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        turnWhite(sender: textField)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        turnWhite(sender: textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        turnWhite(sender: textView)
        return true
    }
    
    func turnWhite(sender: UIView) {
        sender.backgroundColor = UIColor.white
    }
}
