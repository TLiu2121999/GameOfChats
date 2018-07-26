//
//  ViewController.swift
//  GameOfChats
//
//  Created by Tongtong Liu on 7/24/18.
//  Copyright © 2018 Tongtong Liu. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }

    @objc func handleLogout() {
        let loginViewController = LoginViewController()
        present(loginViewController, animated: true)
    }


}

