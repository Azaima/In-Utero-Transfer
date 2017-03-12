//
//  ManageUsersVC.swift
//  IUT
//
//  Created by Ahmed Zaima on 11/03/2017.
//  Copyright © 2017 Ahmed Zaima. All rights reserved.
//

import UIKit

class ManageUsersVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var usersTable: UITableView!
    
    var searchMode = false
    
    var usersInSearch = registeredUsers.sorted(by: { (u1: (key: String, value: Any), u2: (key: String, value: Any)) -> Bool in
        return ((u1.value as! [String:Any])["firstName"] as! String) < ((u2.value as! [String:Any])["firstName"] as! String)
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()

        removeBackButton(self, title: nil)
        usersTable.delegate = self
        usersTable.dataSource = self
        searchBar.delegate = self
    }

   

    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sent = sender as! (key: String, value: Any)
        let destination = segue.destination as! EditUserVC
        destination.userData = sent.value as! [String: Any]
        destination.userID = sent.key
    }
    
    
    //MARK: SearchBar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchFunction(searchBar: searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchFunction(searchBar: searchBar)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        usersInSearch = registeredUsers.sorted(by: { (u1: (key: String, value: Any), u2: (key: String, value: Any)) -> Bool in
            return ((u1.value as! [String:Any])["firstName"] as! String) < ((u2.value as! [String:Any])["firstName"] as! String)
        })
        searchMode = false
    }
    
    func searchFunction(searchBar: UISearchBar) {
        if searchBar.text == nil || searchBar.text == "" {
            usersInSearch = registeredUsers.sorted(by: { (u1: (key: String, value: Any), u2: (key: String, value: Any)) -> Bool in
                return ((u1.value as! [String:Any])["firstName"] as! String) < ((u2.value as! [String:Any])["firstName"] as! String)
            })
            searchMode = false
        }   else {
            searchMode = true
            usersInSearch = registeredUsers.filter({ (userEntry: (key: String, value: Any)) -> Bool in
                return ((userEntry.value as! [String:Any])["firstName"] as! String).lowercased().contains(searchBar.text!.lowercased()) || ((userEntry.value as! [String:Any])["surname"] as! String).lowercased().contains(searchBar.text!.lowercased())
            }).sorted(by: { (u1: (key: String, value: Any), u2: (key: String, value: Any)) -> Bool in
                return ((u1.value as! [String:Any])["firstName"] as! String) < ((u2.value as! [String:Any])["firstName"] as! String)
            })
        }
        
        usersTable.reloadData()

    }
    
    //MARK: Tableview Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if  searchMode {
            return 1
        }   else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchMode {
            return usersInSearch.count
        }   else {
            if section == 0 {
                return usersInSearch.filter({ (userEntry: (key: String, value: Any)) -> Bool in
                    return (userEntry.value as! [String:Any])["newUser"] as? String == "true"
                }).count
            }   else {
                return usersInSearch.filter({ (userEntry: (key: String, value: Any)) -> Bool in
                    return (userEntry.value as! [String:Any])["newUser"] as? String != "true"
                }).count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell")
        
        var listInTable = [(key: String, value: Any)]()
        if searchMode {
            listInTable = usersInSearch
        }   else {
            if indexPath.section == 0 {
                
                listInTable = usersInSearch.filter({ (userEntry: (key: String, value: Any)) -> Bool in
                    return (userEntry.value as! [String:Any])["newUser"] as? String == "true"
                })

            }   else {
                listInTable = usersInSearch.filter({ (userEntry: (key: String, value: Any)) -> Bool in
                    return (userEntry.value as! [String:Any])["newUser"] as? String != "true"
                })
            }
        }
        
        cell?.textLabel?.text = "\(((listInTable[indexPath.row].value as! [String:Any])["firstName"])!) \(((listInTable[indexPath.row].value as! [String:Any])["surname"])!)"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchMode {
            performSegue(withIdentifier: "EditUserVC", sender: usersInSearch[indexPath.row])
        }   else {
            if indexPath.section == 0 {
                performSegue(withIdentifier: "EditUserVC", sender: usersInSearch.filter({ (userEntry: (key: String, value: Any)) -> Bool in
                    return (userEntry.value as! [String:Any])["newUser"] as? String == "true"
                })[indexPath.row])
            }   else {
                performSegue(withIdentifier: "EditUserVC", sender: usersInSearch.filter({ (userEntry: (key: String, value: Any)) -> Bool in
                    return (userEntry.value as! [String:Any])["newUser"] as? String != "true"
                })[indexPath.row])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchMode {
            return "Search Results"
        }   else {
            if section == 0 {
                return "New Users"
            }   else {
                return "Users"
            }
        }
    }

}
