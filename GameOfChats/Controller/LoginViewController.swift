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
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLogRegister), for: .touchUpInside)
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
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "wolf")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileIamgeView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    lazy var loginRegisterSegmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = .white
        sc.layer.cornerRadius = 5
        sc.layer.masksToBounds = true
        sc.selectedSegmentIndex = 1
        sc.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], for: .normal)
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentControl)
        
        setupInputContainerView()
        styleRegisterButton()
        setupProfileImageView()
        setupLoginRegisterSegmentControl()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupProfileImageView() {
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                profileImageView.centerXAnchor.constraint(equalTo: inputContainerView.centerXAnchor),
                profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentControl.topAnchor, constant: -12),
                profileImageView.widthAnchor.constraint(equalToConstant: 150),
                profileImageView.heightAnchor.constraint(equalToConstant: 150)
                
                ])
        }
    }
    
    func setupLoginRegisterSegmentControl() {
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                loginRegisterSegmentControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                loginRegisterSegmentControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12),
                loginRegisterSegmentControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
                loginRegisterSegmentControl.heightAnchor.constraint(equalToConstant: 30)
                ])
        }
    }
    
    var inputContainerViewHeightConstraint: NSLayoutConstraint?
    var nameTextFieldHeightAnchorConstraint: NSLayoutConstraint?
    var emailTextFieldHeightAnchorConstraint: NSLayoutConstraint?
    var passwordTextFieldHeightAnchorConstraint: NSLayoutConstraint?
    
    func setupInputContainerView() {
        inputContainerView.addSubview(nameTextField)
        inputContainerView.addSubview(separatorView1)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(separatorView2)
        inputContainerView.addSubview(passwordTextField)
        
        if #available(iOS 11.0, *) {
            inputContainerViewHeightConstraint = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
            nameTextFieldHeightAnchorConstraint = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
            emailTextFieldHeightAnchorConstraint = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
            passwordTextFieldHeightAnchorConstraint = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
            
            NSLayoutConstraint.activate([
                inputContainerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                inputContainerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                inputContainerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1, constant: -24),
                inputContainerViewHeightConstraint!,
                
                nameTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
                nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
                nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
                nameTextFieldHeightAnchorConstraint!,
                
                separatorView1.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
                separatorView1.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor),
                separatorView1.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
                separatorView1.heightAnchor.constraint(equalToConstant: 1),
                
                emailTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
                emailTextField.topAnchor.constraint(equalTo: separatorView1.bottomAnchor),
                emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
                emailTextFieldHeightAnchorConstraint!,
                
                separatorView2.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
                separatorView2.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor),
                separatorView2.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
                separatorView2.heightAnchor.constraint(equalToConstant: 1),
                
                passwordTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
                passwordTextField.topAnchor.constraint(equalTo: separatorView2.bottomAnchor),
                passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
                passwordTextFieldHeightAnchorConstraint!
                ])
            
        }
    }
    
    func styleRegisterButton() {
        loginRegisterButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                loginRegisterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                loginRegisterButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12),
                loginRegisterButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1, constant: -24),
                loginRegisterButton.heightAnchor.constraint(equalToConstant: 40)
                ])
        }
    }
    
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}


