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

    var messages = [Message]()
    var messagesDict = [String: Message]()
    let cellId = "cellId"
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_message_icon"), style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserLoggedIn()
        observeUserMessage()
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let message = messages[indexPath.row]
        if let chatPartnerId = message.chatPartnerId() {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue { (error, databaseReference) in
                if error != nil {
                    return
                }
                self.messages.remove(at: indexPath.row)
//                self.messagesDict.removeValue(forKey: chatPartnerId)
//                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)

            }
        }
    }
    func checkIfUserLoggedIn() {
        guard (Auth.auth().currentUser?.uid) != nil else {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            return
        }
        fetchUserAndSetupNavBarTitle()
    }
    
    func observeUserMessage() {
    
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded) { (snapshot) in
            let userId = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                let messageRef = Database.database().reference().child("messages").child(messageId)
                messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dict = snapshot.value as? [String: String] {
                        let message = Message()
                        message.fromId = dict["fromId"]
                        message.toId = dict["toId"]
                        message.text = dict["text"]
                        message.timeStamp = dict["timeStamp"]
                        
                        if let chatPartnerId = message.chatPartnerId() {
                            self.messagesDict[chatPartnerId] = message
                            self.messages = Array(self.messagesDict.values)
                            self.messages.sort(by: { (m1, m2) -> Bool in
                                return Int(m1.timeStamp)! > Int(m2.timeStamp)!
                            })
                        }
                        
                        self.timer?.invalidate()
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                        
                    }
                })
            })
            
        }
        
        ref.observe(.childRemoved) { (snapshot) in
            self.messagesDict.removeValue(forKey: snapshot.key)
            self.messages = Array(self.messagesDict.values)
            self.messages.sort(by: { (m1, m2) -> Bool in
                return Int(m1.timeStamp)! > Int(m2.timeStamp)!
            })
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        }
    }
    
    
    @objc func handleReloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).observe(.value) { (dataSnapshot) in
            if let dict = dataSnapshot.value as? [String: Any] {
                let user = User()
                
                user.email = dict["email"] as? String
                user.name = dict["name"] as? String
                user.profileImageURL = dict["profileIamgeURL"] as? String
                
                self.setupNavBarWithUser(user)
            }            
        }
    }
        
    func setupNavBarWithUser(_ user: User){
        messages.removeAll()
        messagesDict.removeAll()
        tableView.reloadData()
        observeUserMessage()
        
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

        self.navigationItem.titleView = titleView
        
    }
    
    
    @objc func showChatControllerForUser(_ user: User) {
        let vc = ChatLogViewController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(vc, animated: true)
        vc.user = user
        vc.inputTextField.becomeFirstResponder()
    }
    
    @objc func handleNewMessage() {
        let newMessageVC = NewMessageTableViewController()
        newMessageVC.messagesViewController = self
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else { return }
        let ref = Database.database().reference().child("users").child(chatPartnerId)
       
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else { return }
            let user = User()
            user.email = dict["email"] as? String
            user.name = dict["name"] as? String
            user.profileImageURL = dict["profileIamgeURL"] as? String
            user.id = chatPartnerId
            self.showChatControllerForUser(user)
        }
    }
}

