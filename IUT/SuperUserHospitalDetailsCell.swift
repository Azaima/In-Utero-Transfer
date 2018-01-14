//
//  SuperUserHospitalDetailsCell.swift
//  IUT
//
//  Created by Ahmed Zaima on 14/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import UIKit
import Firebase
class SuperUserHospitalDetailsCell: UITableViewCell {

    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var usersLabel: UILabel!
    @IBOutlet weak var updateLabel: UILabel!
    @IBOutlet weak var detailsBtn: UIButton!
    @IBOutlet weak var usersBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    
    var hospital: HospitalStructure!
    var updateRecord: CotStatusRecord?
    var usersRecords: [FIRDataSnapshot]?
    var targetVC = "EditHospitalDetailsVC"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

   
    @IBAction func detailButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            targetVC = "EditHospitalDetailsVC"
            detailsBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            usersBtn.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            updateBtn.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        case 1:
            targetVC = "HospitalAdminVC"
            detailsBtn.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            usersBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            updateBtn.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        default:
            targetVC = "UpdateCotsVC"
            detailsBtn.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            usersBtn.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            updateBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        }
    }
    
    
    func initCell(hospital: HospitalStructure, updateRecord: CotStatusRecord?, usersRecords: [FIRDataSnapshot]?){
        self.hospital = hospital
        self.updateRecord = updateRecord
        self.usersRecords = usersRecords
        
        detailsLabel.text = "\(hospital.name!)\n\(hospital.country!)"
        
        
        updateLabel.text = getCotStatus(for: hospital.key, outcome: "brief")
        
        if usersRecords != nil {
            let newUsers = usersRecords!.filter({ (snapshot) -> Bool in
                
                return (snapshot.value as! [String: Any])["entitlements"] == nil
            })
            
            usersLabel.text = "\(usersRecords!.count) users.\n\(newUsers.count) new users found."
        }   else {
            usersLabel.text = "No users are found."
        }
    }
}
