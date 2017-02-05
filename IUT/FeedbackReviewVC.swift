//
//  FeedbackReviewVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 05/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit

class FeedbackReviewVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bodyText: UITextView!
    
    var messageDict = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = messageDict["title"] as! String
        authorLabel.text = messageDict["username"] as! String
        bodyText.text = messageDict["body"] as! String
    }

        

    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        formatter.dateFormat = "dd-MM-yy HH:mm"
        messageDict["reviewDetails"] = ["reviewDate": formatter.string(from: date), "reviewedBy": loggedInUserID!]
        let messageTitle = messageDict["title"] as! String
        messageDict["title"] = nil
        
        DataService.ds.archiveFeedback( title: messageTitle, message: messageDict)
        _ = navigationController?.popViewController(animated: true)
    }
    
}
