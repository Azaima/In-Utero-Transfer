//
//  AdministrativeToolsVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 04/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit

class AdministrativeToolsVC: UIViewController {

    @IBOutlet weak var hospitalDBButton: UIButton!
    @IBOutlet weak var hospitalDetailsButton: UIButton!
    @IBOutlet weak var linkedUsersButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        removeBackButton(self, title: nil)
        setupView()
    }
    
    func setupView() {
        if loggedInUserData?["hospital"] as? String == "" && loggedInUserData?["adminRights"] as? String == "true" || loggedInUserData?["superUser"] as? String == "true" {
            hospitalDBButton.isHidden = false
        }
        
        if loggedInUserData?["hospital"] as? String != "" && loggedInUserData?["adminRights"] as? String == "true" || loggedInUserData?["superUser"] as? String == "true" {
            hospitalDetailsButton.isHidden = false
        }
        
        if  loggedInUserData?["adminRights"] as? String == "true" || loggedInUserData?["superUser"] as? String == "true" {
            linkedUsersButton.isHidden = false
        }
        
        if  loggedInUserData?["feedbackRights"] as? String == "true" || loggedInUserData?["superUser"] as? String == "true" {
            feedbackButton.isHidden = false
        }
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

    @IBAction func linkedUsersPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "UsersTableVC", sender: nil)
    }
}
