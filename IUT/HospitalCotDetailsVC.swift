//
//  HospitalCotDetailsVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 09/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import UIKit

class HospitalCotDetailsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var pageTitle: UINavigationItem!
    @IBOutlet weak var detailsTable: UITableView!
    var key = ""
    var hospital: HospitalStructure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hospital = hospital != nil ? hospital : hospitals[hospitals.index(where: { (hospital: HospitalStructure) -> Bool in
            return hospital.key == key
        })!]
        removeBackButton(self, title: nil)
        detailsTable.delegate = self
        detailsTable.dataSource = self
        detailsTable.reloadData()
        pageTitle.title = hospital!.name
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let details = [hospital!.network, "\((hospital!.level)!)", hospital!.subspecialty, getCotStatus(for: key, outcome: "details"),hospital!.switchBoard, hospital!.nicu, hospital!.nicuCoordinator, hospital!.labourWard, hospital!.address]
        let titles = ["Network", "Level", "Subspecialty", "Cot Status", "Switch Board", "NICU", "NICU Coordinator", "Labour Ward", "Address"]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HospitalDetailsCell") as! HospitalDetailsCell
        
        cell.initCell(detailName: titles[indexPath.row], details: (details[indexPath.row])!)
        return cell
    }

}
