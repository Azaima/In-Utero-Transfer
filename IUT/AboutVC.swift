//
//  AboutVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 12/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        DB_BASE.child("aboutMessage").observe(.value, with: { (messageSnap) in
            
            if let message = messageSnap.value as? [String: Any] {
                for msg in message {
                    self.textView.text = msg.value as! String
                }
            }
        })
        
        removeBackButton(self, title: nil)
    }

}

