//
//  LoginViewController.swift
//  GameOfChats
//
//  Created by Tongtong Liu on 7/24/18.
//  Copyright © 2018 Tongtong Liu. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    let inputContainerView: UIView = {
        let inputContainerView = UIView()
        inputContainerView.backgroundColor = .white
        inputContainerView.layer.cornerRadius = 5
        inputContainerView.layer.masksToBounds = true
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        return inputContainerView
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    let nameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Name"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let separatorView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let passwordTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let separatorView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "wolf")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputContainerView)
        view.addSubview(registerButton)
        view.addSubview(profileImageView)
        
        setupInputContainerView()
        styleRegisterButton()
        setupProfileImageView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else { return }


        Auth.auth().createUser(withEmail: email, password: password, completion: {
            (authResult, error) in
            if error != nil {
                return
            }
            guard let uid = authResult?.user.uid else { return }
            let ref = Database.database().reference()
            let usersRed = ref.child("users").child(uid)
            let values = ["name": name, "email": email]
            usersRed.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                print("Success!!!!!")
            })
        })
    }
    
    func setupProfileImageView() {
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                profileImageView.centerXAnchor.constraint(equalTo: inputContainerView.centerXAnchor),
                profileImageView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12),
                profileImageView.widthAnchor.constraint(equalToConstant: 150),
                profileImageView.heightAnchor.constraint(equalToConstant: 150)
                
            ])
        }
    }
    
    func setupInputContainerView() {
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                inputContainerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                inputContainerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                inputContainerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1, constant: -24),
                inputContainerView.heightAnchor.constraint(equalToConstant: 150)
            ])
        }
        
        inputContainerView.addSubview(nameTextField)
        inputContainerView.addSubview(separatorView1)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(separatorView2)
        inputContainerView.addSubview(passwordTextField)
        
        if #available(iOS 11.0, *) {
            
            NSLayoutConstraint.activate([
                nameTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
                nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
                nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
                nameTextField.heightAnchor.constraint(equalToConstant: 50),
                
                separatorView1.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
                separatorView1.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor),
                separatorView1.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
                separatorView1.heightAnchor.constraint(equalToConstant: 1),
                
                emailTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
                emailTextField.topAnchor.constraint(equalTo: separatorView1.bottomAnchor),
                emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
                emailTextField.heightAnchor.constraint(equalToConstant: 50),
                
                separatorView2.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
                separatorView2.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor),
                separatorView2.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
                separatorView2.heightAnchor.constraint(equalToConstant: 1),
                
                passwordTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
                passwordTextField.topAnchor.constraint(equalTo: separatorView2.bottomAnchor),
                passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
                passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            ])
            
        }
    }
    
    func styleRegisterButton() {
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                registerButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                registerButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12),
                registerButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1, constant: -24),
                registerButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    }
    
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}


