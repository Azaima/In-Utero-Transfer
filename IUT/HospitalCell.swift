//
//  HospitalCell.swift
//  IUT
//
//  Created by Ahmed Zaima on 11/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import UIKit

class HospitalCell: UITableViewCell {

    @IBOutlet weak var hospitalNameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    var hospital: HospitalStructure?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    func initCell(hospital: HospitalStructure){
        hospitalNameLabel.text = hospital.name
        subtitleLabel.text = getCotStatus(for: hospital.key, outcome: "brief")
        self.hospital = hospital
        switch hospital.level {
        case 1:
            self.backgroundColor = UIColor(red: 250/255, green: 255/255, blue: 1/255, alpha: 0.25)
        case 2:
            self.backgroundColor = UIColor(red: 1/255, green: 255/255, blue: 18/255, alpha: 0.25)
        case 3:
            self.backgroundColor = UIColor(red: 1/255, green: 157/255, blue: 255/255, alpha: 0.25)
        default:
            self.backgroundColor = UIColor.white
        }
    }
}
