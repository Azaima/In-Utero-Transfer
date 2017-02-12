//
//  AddNewRegionVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 12/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit

class AddNewRegionVC: UIViewController {

    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var regionField: UITextField!
    @IBOutlet weak var networkView: UITextView!
    
    var newNetworks = [String]()
    var networkEntry = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        removeBackButton(self, title: "Cancel")
    }

    @IBAction func completePressed(_ sender: Any) {
        
        if countryField.text != "" && regionField.text != "" && networkView.text != "" {
            
            for char in networkView.text.characters {
                if char == "\n" {
                    newNetworks.append(networkEntry)
                    networkEntry = ""
                }   else {
                    networkEntry.append(char)
                }
                
            }
            
            newNetworks.append(networkEntry)
            
            DataService.ds.createRegion(country: countryField.text!, region: regionField.text!, networks: newNetworks)
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
   
    
}
