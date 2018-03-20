//
//  UpdateCotsVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 13/01/2018.
//  Copyright © 2018 Ahmed Zaima. All rights reserved.
//

import UIKit

class UpdateCotsVC: UIViewController{

    @IBOutlet weak var lastUpdateLAbel: UILabel!
    @IBOutlet weak var inHouseField: UITextField!
    @IBOutlet weak var inNetworkField: UITextField!
    @IBOutlet weak var scbuField: UITextField!
    @IBOutlet weak var nicuStack: UIStackView!
    @IBOutlet weak var nicuField: UITextField!
    @IBOutlet weak var subspecialtyStack: UIStackView!
    @IBOutlet weak var subspecialtyField: UITextField!
    @IBOutlet weak var cotCommentsField: UITextView!
    @IBOutlet weak var pageScroll: UIScrollView!
    
    var lastUpdate: CotStatus?
    
    var hospital: HospitalStructure?
    
    let alertMessage = UIAlertController(title: nil, message: "", preferredStyle: UIAlertControllerStyle.alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeBackButton(self, title: nil)
        alertMessage.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        if hospital != nil {
            if let updatesRecord = cotStatusRecords[hospital!.key] {
                setUpdateValues(update: updatesRecord.updates.last!)
            }   else {
                lastUpdateLAbel.text = "Cot status has never been updated"
            }
        }   else {
            alertMessage.message = "User data has not loaded."
            present(alertMessage, animated: true, completion: nil)
            
        }
    }

    func setUpdateValues(update: CotStatus){
        lastUpdateLAbel.text = update.timeStr!
        
        inHouseField.text = "\(update.inHouse!)"
        inNetworkField.text = "\(update.inNetwork!)"
        scbuField.text = "\(update.scbu!)"
        nicuField.text = "\(update.nicu!)"
        subspecialtyField.text = "\(update.subspecialty!)"
        cotCommentsField.text = "\(update.comments!)"
        nicuStack.isHidden = hospital!.level < 2
        subspecialtyStack.isHidden = hospital!.level < 3
    }
    
    @IBAction func textfieldDidSelect(_ sender: UITextField) {
        pageScroll.setContentOffset(sender.center, animated: true)
    }
    
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        if hospital!.key != "ebs-uk" {
            let fields = [inHouseField, inNetworkField, scbuField, nicuField, subspecialtyField]
            let fieldTitles = ["inHouse", "inNetwork", "scbu", "nicu", "subspecialty"]
            var update = [
                "time": dateFormatter.string(from: Date()),
                "user": (sessionData?.uid)!,
                "comments": cotCommentsField.text,
                "inHouse": 0,
                "inNetwork": 0,
                "scbu": 0,
                "nicu": 0,
                "subspecialty": 0
                ] as [String : Any]
            
            for (index, field) in fields.enumerated() {
                if let valueText = field?.text {
                    let value = Int(valueText) != nil ? Int(valueText)! : 0
                    update[fieldTitles[index]] = value
                }
            }
            
            let updateKey = COTFINDER2_REF.child("cotStatus").child(hospital!.key).childByAutoId().key
            
            let lastUpdateObject = [
                "key": updateKey,
                "time": update["time"]!,
                "user": (sessionData?.uid)!
            ]
            
            COTFINDER2_REF.child("cotStatus").child(hospital!.key).child(updateKey).updateChildValues(update)
            COTFINDER2_REF.child("cotStatus").child(hospital!.key).child("lastUpdate").updateChildValues(lastUpdateObject)
            
            navigationController?.popViewController(animated: true)
        }   else {
            alertMessage.message = "Error\nAttempting to update the cot status for the Emergency Bed Service."
            present(alertMessage, animated: true, completion: nil)
        }
    }
}
