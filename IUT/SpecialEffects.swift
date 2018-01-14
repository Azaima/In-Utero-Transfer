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

var cornerRadius: CGFloat = 0
var showingBorder = false

extension UIView {
    @IBInspectable var roundedCorners: CGFloat {
        get {
            return cornerRadius
        }
        
        set {
            cornerRadius = newValue
            
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
    
    
    @IBInspectable var showBorder: Bool {
        set {
            if newValue {
                
                showingBorder = newValue
                
                if showingBorder {
                    self.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 10)
                    self.layer.borderColor = CGColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 1)
                    self.layer.borderWidth = 1
                    
                }
            }
        }
        
        get {
            return showingBorder
        }
        
    }
}


