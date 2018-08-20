//
//  NewMessageTableViewController.swift
//  GameOfChats
//
//  Created by Tongtong Liu on 7/26/18.
//  Copyright © 2018 Tongtong Liu. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTableViewController: UITableViewController {

    let cellId = "cellId"
    var users = [User]()
    var messagesViewController: MessagesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUsers()
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }

    func fetchUsers() {
        Database.database().reference().child("users").observe(.childAdded) { (dataSnapshot) in
            if let dict = dataSnapshot.value as? [String: Any] {
                let user = User()
                
                user.id = dataSnapshot.key
                user.email = dict["email"] as? String
                user.name = dict["name"] as? String
                user.profileImageURL = dict["profileIamgeURL"] as? String
                
                self.users.append(user)
                self.tableView.reloadData()
            }   
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let profileImageURL = user.profileImageURL {
            cell.profileImageView.loadImageUsingCacheWithURLString(urlString: profileImageURL)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true)
        let user = users[indexPath.row]
        self.messagesViewController?.showChatControllerForUser(user)
        
    }
}

