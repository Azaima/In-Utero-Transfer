//
//  UserAdminCell.swift
//  IUT
//
//  Created by Ahmed Zaima on 13/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import UIKit

class UserAdminCell: UITableViewCell {

    @IBOutlet weak var newUserBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var updateCotsBtn: UIButton!
    @IBOutlet weak var adminBtn: UIButton!
    
    var hospital: HospitalStructure?
    
    var userRecord: UserAdminRecord? {
        didSet{
            if userRecord != nil {
                if userRecord?.admin == nil || userRecord?.updateCots == nil {
                    newUserBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
                }   else {
                    adminBtn.tag = userRecord!.admin! ? 1 : 0
                    let imgForAdmin = adminBtn.tag == 1 ? #imageLiteral(resourceName: "checked") : #imageLiteral(resourceName: "unchecked")
                    adminBtn.setImage(imgForAdmin, for: .normal)
                    
                    updateCotsBtn.tag = userRecord!.updateCots! ? 1 : 0
                    let imgForCutUpdate = updateCotsBtn.tag == 1 ? #imageLiteral(resourceName: "checked") : #imageLiteral(resourceName: "unchecked")
                    updateCotsBtn.setImage(imgForCutUpdate, for: .normal)
                    
                    adminBtn.alpha = userRecord!.key == sessionData?.uid ? 0.25 : 1
                    updateCotsBtn.alpha = userRecord!.key == sessionData?.uid ? 0.25 : 1
                    
                    adminBtn.isUserInteractionEnabled = userRecord!.key != sessionData?.uid
                    updateCotsBtn.isUserInteractionEnabled = userRecord!.key != sessionData?.uid
                    
                    newUserBtn.isUserInteractionEnabled = false
                    
                    
                }
                
                nameLabel.text = "\(userRecord!.firstName) \(userRecord!.surname)"
                
                emailLabel.text = userRecord!.email
                
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func userFileChanged(_ sender: UIButton) {
        if userRecord!.key != sessionData?.uid {
            newUserBtn.isUserInteractionEnabled = false
            newUserBtn.setImage(nil, for: .normal)
           
            if sender == updateCotsBtn {
                updateCotsBtn.tag = updateCotsBtn.tag == 1 ? 0 : 1
                let imgForCotUpdate = updateCotsBtn.tag == 1 ? #imageLiteral(resourceName: "checked") : #imageLiteral(resourceName: "unchecked")
                updateCotsBtn.setImage(imgForCotUpdate, for: .normal)
                
            }   else if sender == adminBtn {
                adminBtn.tag = adminBtn.tag == 1 ? 0 : 1
                let imgForAdimn = adminBtn.tag == 1 ? #imageLiteral(resourceName: "checked") : #imageLiteral(resourceName: "unchecked")
                adminBtn.setImage(imgForAdimn, for: .normal)
            }
            
            let cotUpdate = updateCotsBtn.tag == 1 ? "true" : "false"
            let admin = adminBtn.tag == 1 ? "true" : "false"
            
            let entitlements = ["entitlements": ["admin": admin, "updateCots": cotUpdate]]
            
            COTFINDER2_REF.child("usersByHospital").child(hospital!.key).child(userRecord!.key).updateChildValues(entitlements)
        }
    }
    
    
    
    
}
