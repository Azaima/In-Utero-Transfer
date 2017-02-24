//
//  FeedbackListVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 05/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit
import Firebase

class FeedbackListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var hospital = ""
    @IBOutlet weak var feedbackTable: UITableView!
    
    var feedbackList = [[String:Any]](){
        didSet{
            feedbackTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        feedbackTable.delegate = self
        feedbackTable.dataSource = self
        removeBackButton(self, title: nil)
        hospital = loggedInUserData?["hospital"] as! String
        setupData()
    }

    func setupData() {
        var list = [[String:Any]]()
        DataService.ds.REF_FEEDBACK.child(country).child(loggedInUserRegion).child(hospital).observe(.value, with: { (feedbackSnapshot) in
            list = []
            let feedSnaps = feedbackSnapshot.children.allObjects as! [FIRDataSnapshot]
            for snap in feedSnaps {
                var message = snap.value as! [String: Any]
                message["title"] = snap.key
                list.append(message)
            }
            
            self.feedbackList = list
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! FeedbackCell
        configureCell(cell: cell, messageDict: feedbackList[indexPath.row])
        return cell
    }
    
    func configureCell(cell: FeedbackCell, messageDict: [String: Any]){
        
        cell.titleLabel.text = (messageDict["title"] as? String != nil) ? (messageDict["title"] as? String)! : ""
        if let author = messageDict["username"] as? String {
            cell.senderLabel.text = author
        }
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "FeedbackReviewVC", sender: feedbackList[indexPath.row])
    }
    
    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! FeedbackReviewVC
        destination.messageDict = sender as! [String:Any]
        
    }
    

}
