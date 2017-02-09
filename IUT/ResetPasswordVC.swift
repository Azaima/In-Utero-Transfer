//
//  ResetPasswordVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 07/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordVC: UIViewController {

    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        removeBackButton(self, title: nil)
    }

   
    @IBAction func resetPressed(_ sender: UIButton) {
        if emailField.text != nil {
            FIRAuth.auth()?.sendPasswordReset(withEmail: emailField.text!, completion: { (error) in
                if error != nil {
                    self.statusLabel.textColor = UIColor.red
                    self.statusLabel.text = "\((error?.localizedDescription)!)"
                }   else {
                    self.statusLabel.textColor = UIColor.black
                    self.statusLabel.text = "A password reset email has been sent to your account. Please follow the link to reset your password."
                    self.resetButton.isHidden = true
                }
            })
        }
    }
    

}
