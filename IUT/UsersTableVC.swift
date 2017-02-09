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
    var completeList = [[String: Any]]()
    
    
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
        
        DataService.ds.REF_USER_BYHOSPITAL.child(loggedHospitalName!).observe( .value, with: { (hospitalUsersSnapshot) in
            self.allHospitalUsers = []
            
            let hospitalUsers = hospitalUsersSnapshot.children.allObjects as! [FIRDataSnapshot]
            
            for hospUser in hospitalUsers {
                var user = hospUser.value as? [String: Any]
                user?["userID"] = hospUser.key
                self.allHospitalUsers.append(user!)
            }
            
            self.newHospitalUsers = self.allHospitalUsers.filter({ (user: [String : Any]) -> Bool in
                return user["newUser"] as? String == "true"
            })
            
            self.existingHospitalUsers = self.allHospitalUsers.filter({ (user: [String : Any]) -> Bool in
                return user["newUser"] as? String != "true"
            })
            
            self.usersTable.reloadData()
        })
        
    }
    
    func checkAndAppend(array: inout [[String:Any]], userData: [String: Any]) {
        
        if array.contains(where: { (dict: [String : Any]) -> Bool in
            return dict["userID"] as! String == userData["userID"] as! String
        }) {
            array[array.index(where: { (dict: [String : Any]) -> Bool in
                return dict["userID"] as! String == userData["userID"] as! String
            })!] = userData
            
        }   else {
            array.append(userData)
        }
    }
 
    
    //MARK: SearchBar delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            searching = false
        }   else {
            searching = true
            searchingNewUsers = newHospitalUsers.filter({ (user: [String : Any]) -> Bool in
                return (user["name"] as! String).lowercased().contains(searchBar.text!.lowercased())
            })
            
            searchingExistingUsers = existingHospitalUsers.filter({ (user: [String : Any]) -> Bool in
                return (user["name"] as! String).lowercased().contains(searchBar.text!.lowercased())
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
                cell?.textLabel?.text = "\((searchingNewUsers[indexPath.row]["name"])!)"
            default:
                cell?.textLabel?.text = "\((searchingExistingUsers[indexPath.row]["name"])!)"
            }
        }   else {
            switch indexPath.section {
            case 0:
                cell?.textLabel?.text = "\((newHospitalUsers[indexPath.row]["name"])!)"
            default:
                cell?.textLabel?.text = "\((existingHospitalUsers[indexPath.row]["name"])!)"
            }
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if searching {
            switch indexPath.section {
            case 0:
                selectedUser = searchingNewUsers[indexPath.row]
                
            default:
                selectedUser = searchingExistingUsers[indexPath.row]
            }
        } else {
            switch indexPath.section {
            case 0:
                selectedUser = newHospitalUsers[indexPath.row]
                
            default:
                selectedUser = existingHospitalUsers[indexPath.row]
            }
        }
        
        performSegue(withIdentifier: "ReviewUserVC", sender: nil)
    }

    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        let destination = segue.destination as! ReviewUserVC
        destination.selectedUser = selectedUser
        
    }
    

}
