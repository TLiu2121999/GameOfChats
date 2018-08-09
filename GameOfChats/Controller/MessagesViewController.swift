//
//  MessagesViewController.swift
//  GameOfChats
//
//  Created by Tongtong Liu on 7/24/18.
//  Copyright © 2018 Tongtong Liu. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_message_icon"), style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserLoggedIn()
    }
    
    @objc func handleNewMessage() {
        let newMessageVC = NewMessageTableViewController()
        let navController = UINavigationController(rootViewController: newMessageVC)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserLoggedIn() {
        guard (Auth.auth().currentUser?.uid) != nil else {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            return
        }
        fetchUserAndSetupNavBarTitle()
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid =  Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).observe(.value) { (dataSnapshot) in
            if let dict = dataSnapshot.value as? [String: Any] {
                self.navigationItem.title = dict["name"] as? String
                let user = User()
                user.setValuesForKeys(dict)
                self.setupNavBarWithUser(user: user)
            }
            
            print(dataSnapshot)
        }
    }
    
    func setupNavBarWithUser(user: User){
        self.navigationItem.title = user.name
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        
        let loginViewController = LoginViewController()
        loginViewController.messagesViewController = self
        present(loginViewController, animated: true)
    }
}

