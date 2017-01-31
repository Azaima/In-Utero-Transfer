//
//  ShadowEffect.swift
//  CliniCompanion
//
//  Created by Ahmed Zaima on 20/11/2016.
//  Copyright © 2016 Ahmed Zaima. All rights reserved.
//

import UIKit

var shadowSelected = false
var shadowColor = UIColor(red: 157 / 255, green: 157 / 255, blue: 157 / 255, alpha: 1.0).cgColor

extension UIView {

    @IBInspectable var shadowEffect: Bool {
        
        get {
            return shadowSelected
        }
        
        set {
            
            shadowSelected = newValue
            
            if shadowSelected {
                
                self.layer.cornerRadius = 5
                self.layer.shadowColor = shadowColor
                self.layer.shadowRadius = 3
                self.layer.shadowOffset = CGSize(width: 2, height: 2)
                self.layer.shadowOpacity = 0.8
                self.layer.masksToBounds = false
            }   else {
                
                self.layer.cornerRadius = 0
                self.layer.shadowOpacity = 0
                self.layer.shadowRadius = 0
                self.layer.shadowColor = nil
                
            }
        }
    }

}
