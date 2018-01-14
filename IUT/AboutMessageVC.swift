//
//  AboutMessageVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 07/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import UIKit

class AboutMessageVC: UIViewController {
    
    @IBOutlet weak var aboutMessageField: UITextView!
    @IBOutlet weak var pageTitleField: UINavigationItem!
    var messageForDisplay = ""
    var pageTitle = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        removeBackButton(self, title: "")
        pageTitleField.title = pageTitle
        COTFINDER2_REF.child(messageForDisplay).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let message = snapshot.value as? String {
                
                self.aboutMessageField.text = message
                
            }
        }) 
    }

    
    

    

}
