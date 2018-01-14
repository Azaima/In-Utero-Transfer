//
//  HospitalDetailsCell.swift
//  IUT
//
//  Created by Ahmed Zaima on 09/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import UIKit

class HospitalDetailsCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var detailsField: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    func initCell(detailName: String, details: String){
        headerLabel.text = detailName
        detailsField.text = details
        detailsField.clipsToBounds = false
        detailsField.isHidden = details == ""
        
    }
}
