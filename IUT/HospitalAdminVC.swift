//
//  HospitalAdminVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 13/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import UIKit
import Firebase

class HospitalAdminVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pageTitle: UINavigationItem!
    @IBOutlet weak var usersTable: UITableView!
    
    let alertMessage = UIAlertController(title: nil, message: "", preferredStyle: UIAlertControllerStyle.alert)
    var userSnaps = [FIRDataSnapshot]() {
        didSet {
            userSnaps.sort { (snapA, snapB) -> Bool in
                
                let snapADetails = ((snapA.value as! [String: Any])["details"]! as! [String:String])
                let snapBDetails = ((snapB.value as! [String: Any])["details"]! as! [String:String])
                return snapADetails["firstName"]! < snapBDetails["firstName"]!
            }
            
            usersTable.reloadData()
        }
    }
    
    var hospital: HospitalStructure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertMessage.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        removeBackButton(self, title: nil)
        pageTitle.title = (userData["hospitalStructure"]! as! HospitalStructure).name
        
        usersTable.delegate = self
        usersTable.dataSource = self
        
        hospital = hospital == nil ? userData["hospitalStructure"] as! HospitalStructure : hospital
        
        COTFINDER2_REF.child("usersByHospital").child(hospital!.key).observe(FIRDataEventType.value, with: { (usersSnapshot) in
            
            if usersSnapshot != nil {
                self.userSnaps = usersSnapshot.children.allObjects as! [FIRDataSnapshot]
                
            }   else {
                self.alertMessage.message = "No users are listed for this hospital"
                self.present(self.alertMessage, animated: true, completion: nil)
                
            }
        })
        
        usersTable.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userSnaps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserAdminCell") as! UserAdminCell
        
        cell.userRecord = UserAdminRecord(userFileSnap:  userSnaps[indexPath.row])
        return cell
    }

 

}
