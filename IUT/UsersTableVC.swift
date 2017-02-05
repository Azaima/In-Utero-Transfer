//
//  UsersTableVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 05/02/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit
import Firebase

class UsersTableVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var usersTable: UITableView!
    
    var searching = false
    
    var selectedUser = [String:Any]()
    var newUser = false
    
    var allHospitalUsers = [[String: Any]]() {
        didSet {
            usersTable.reloadData()
        }
    }
    
    var newHospitalUsers = [[String: Any]]()
    var existingHospitalUsers = [[String: Any]]()
    
    var searchingNewUsers = [[String:Any]]()
    var searchingExistingUsers = [[String:Any]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        removeBackButton(self, title: nil)
        usersTable.delegate = self
        usersTable.dataSource = self
        searchBar.delegate = self
        
        getCompleteList()
    }

    //MARK: Getting the data from Firebase
    
    func getCompleteList() {
        var completeList = [[String:Any]]()
        var newList = [[String: Any]]()
        var existingList = [[String:Any]]()
        
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            completeList = []
            if let snapShot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapShot {
                    var userData = snap.value as! [String:Any]
                    
                     if (userData["hospital"]!) as? String == (loggedInUserData?["hospital"] as! String) {
                        
                        userData["userID"] = snap.key
                        completeList.append(userData)
                    }
                    
                }
            }
            
            DataService.ds.REF_NEWUSER.observe(.value, with: { (snapshot) in
                newList = []
                existingList = []
                let snapShot = snapshot.children.allObjects as! [FIRDataSnapshot]
                
                for userData in completeList {
                    if snapShot.contains(where: { (FIRDataSnapshot) -> Bool in
                        return FIRDataSnapshot.key == userData["userID"] as! String
                    }) {
                        newList.append(userData)
                        
                    }   else {
                        existingList.append(userData)
                    }
                }
             
                self.newHospitalUsers = newList
                self.existingHospitalUsers = existingList
                self.allHospitalUsers = completeList
            })
            
            
        })
    }
    
    
    //MARK: SearchBar delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            searching = false
        }   else {
            searching = true
            searchingNewUsers = newHospitalUsers.filter({ (user: [String : Any]) -> Bool in
                return (user["firstName"] as! String).lowercased().contains(searchBar.text!.lowercased()) || (user["surname"] as! String).lowercased().contains(searchBar.text!.lowercased())
            })
            
            searchingExistingUsers = existingHospitalUsers.filter({ (user: [String : Any]) -> Bool in
                return (user["firstName"] as! String).lowercased().contains(searchBar.text!.lowercased()) || (user["surname"] as! String).lowercased().contains(searchBar.text!.lowercased())
            })
        }
        
        usersTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: Tableview Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searching {
            switch section {
            case 0:
                return searchingNewUsers.count
            default:
                return searchingExistingUsers.count
            }
        }   else {
            switch section {
            case 0:
                return newHospitalUsers.count
            default:
                return existingHospitalUsers.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "New Users"
        default:
            return "Existing Users"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell")
        
        if searching {
            switch indexPath.section {
            case 0:
                cell?.textLabel?.text = "\((searchingNewUsers[indexPath.row]["firstName"])!) \((searchingNewUsers[indexPath.row]["surname"])!)"
            default:
                cell?.textLabel?.text = "\((searchingExistingUsers[indexPath.row]["firstName"])!) \((searchingExistingUsers[indexPath.row]["surname"])!)"
            }
        }   else {
            switch indexPath.section {
            case 0:
                cell?.textLabel?.text = "\((newHospitalUsers[indexPath.row]["firstName"])!) \((newHospitalUsers[indexPath.row]["surname"])!)"
            default:
                cell?.textLabel?.text = "\((existingHospitalUsers[indexPath.row]["firstName"])!) \((existingHospitalUsers[indexPath.row]["surname"])!)"
            }
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if searching {
            switch indexPath.section {
            case 0:
                selectedUser = searchingNewUsers[indexPath.row]
                newUser = true
            default:
                selectedUser = searchingExistingUsers[indexPath.row]
            }
        } else {
            switch indexPath.section {
            case 0:
                selectedUser = newHospitalUsers[indexPath.row]
                newUser = true
            default:
                selectedUser = existingHospitalUsers[indexPath.row]
            }
        }
        
        performSegue(withIdentifier: "ReviewUserVC", sender: nil)
    }

    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        let destination = segue.destination as! ReviewUserVC
        destination.userDict = selectedUser
        destination.newUser = newUser
    }
    

}
