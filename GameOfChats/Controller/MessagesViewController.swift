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
    
    
    
    func checkIfUserLoggedIn() {
        guard (Auth.auth().currentUser?.uid) != nil else {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            return
        }
        fetchUserAndSetupNavBarTitle()
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).observe(.value) { (dataSnapshot) in
            if let dict = dataSnapshot.value as? [String: Any] {
                //self.navigationItem.title = dict["name"] as? String
                let user = User()
                
                user.email = dict["email"] as? String
                user.name = dict["name"] as? String
                user.profileImageURL = dict["profileIamgeURL"] as? String
                
                self.setupNavBarWithUser(user)
            }
            
            print(dataSnapshot)
        }
    }
    
    
    func setupNavBarWithUser(_ user: User){
        let titleView = UIButton()
        
        let containerView = UIView()
        titleView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor)
            ])

        
        // Set up ProfileImageView
        let profileImageView = UIImageView()
        containerView.addSubview(profileImageView)
        
        profileImageView.frame = CGRect(x: 50, y: 0, width: 40, height: 40)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        if let imageURL = user.profileImageURL {
            profileImageView.loadImageUsingCacheWithURLString(urlString: imageURL)
        }
        
        
        NSLayoutConstraint.activate([
            profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40)
            ])

        
        // Set up Name label view
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.frame = CGRect(x: 48, y: 0, width: nameLabel.intrinsicContentSize.width, height: 40)
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8),
            nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 40)

            ])

        titleView.addTarget(self, action: #selector(showChatController), for: .touchUpInside)
        self.navigationItem.titleView = titleView
        
    }
    
    
    @objc func showChatController() {
        
        let vc = ChatLogViewController(collectionViewLayout: UICollectionViewLayout())
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func handleNewMessage() {
        let newMessageVC = NewMessageTableViewController()
        let navController = UINavigationController(rootViewController: newMessageVC)
        present(navController, animated: true, completion: nil)
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

