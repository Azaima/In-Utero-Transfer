//
//  AdministrativeToolsVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 04/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit

class AdministrativeToolsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        removeBackButton(self, title: nil)
    }

    @IBAction func showHospitalDetails(_ sender: UIButton) {
        performSegue(withIdentifier: "singleHospitalDetails", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "singleHospitalDetails" {
            let destination = segue.destination as! HospitalDetailsVC
            destination.hospital = loggedInUserHospital
        }
    }

}
