//
//  MainVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 30/01/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit
import CoreLocation

class MainVC: UIViewController {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.prepareDataBase {
            self.activityIndicator.stopAnimating()
            self.stack.isHidden = false
        }
    }

    func prepareDataBase(complete: @escaping DownloadComplete) {

        DataService.ds.REF_HOSPITALS.observe(.value, with: { (snap) in
            
            let snapShot = snap.value as! [String: [String:Any]]
            let snapShotsorted = snapShot.sorted(by: { (v1: (key: String, value: Any), v2:(key: String, value: Any)) -> Bool in
                return v1.key < v2.key
            })
            
            for (key,value) in snapShotsorted{
                let hospital = HospitalStruct(name: key, address: value["address"] as! String, location: CLLocation(latitude: (value["location"] as! [String: Double])["latitude"]!, longitude: (value["location"] as! [String: Double])["longitude"]!), network: value["network"] as! String, level: value["level"] as! Int, distanceFromMe: 2.2, subspeciality: value["subspeciality"] as? String, switchBoard: value["switchBoard"] as! String, nicuNumber: value["nicu"] as! String, nicuCoordinator: value["nicuCoordinator"] as? String, labourWard: value["labourWard"] as! String)
                
                hospitalsArray.append(hospital)
                print("\(hospital.name): \(hospital.network)")
            }
            
            complete()
            print(hospitalsArray.count)
        })
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignInVC" {
            let destination = segue.destination as! SignInVC
            destination.register = sender as! Bool
        }
    }

    @IBAction func signinPressed(_ sender: UIButton) {
        let register = sender.tag == 1 ? true : false
        performSegue(withIdentifier: "SignInVC", sender: register)
    }
    
}

