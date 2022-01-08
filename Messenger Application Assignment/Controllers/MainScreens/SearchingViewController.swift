//
//  SearchingViewController.swift
//  Messenger Application Assignment
//
//  Created by administrator on 07/01/2022.
//

import UIKit
import FirebaseDatabase

class SearchingViewController: UIViewController
{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var users: [ChatAppUser] = []
    var filteredData: [ChatAppUser] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.tableFooterView = UIView()
        self.tableView.keyboardDismissMode = .onDrag
        
        getAllUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    func getAllUser(){
        Database.database().reference(withPath: "users").observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() { return }
            
            
            let snap = snapshot.value as! [String:AnyObject]
            for s in snap{
//                print(s)
//                print("-=-=-=-=-=-=-=-=-=-=-")
                self.users.append(ChatAppUser(name: s.value["name"] as! String, emailAddress: s.key))
            }
            
        }
    }
    
}


extension SearchingViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if filteredData.count > 30
        {
            return 30
        }
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserResultCell", for: indexPath) as! UserTableViewCell
        
        cell.userName.text = filteredData[indexPath.row].name
        cell.userEmail.text = filteredData[indexPath.row].emailAddress
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "OpenChatFromSearch", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ChatViewController
        let indexPath = sender as! IndexPath
        destination.freind = filteredData[indexPath.row]
    }
}



extension SearchingViewController: UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = []
        
        if searchText == ""
        {
            filteredData = []
        }
        else
        {
            for user in users
            {
                if user.emailAddress.uppercased().contains(searchText.uppercased())
                {
                    filteredData.append(user)
                }
            }
        }
        
        self.tableView.reloadData()
    }
}
