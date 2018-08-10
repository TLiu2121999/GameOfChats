//
//  ChatLogViewController.swift
//  GameOfChats
//
//  Created by Tongtong Liu on 8/9/18.
//  Copyright © 2018 Tongtong Liu. All rights reserved.
//

import WebKit
import Firebase

class ChatLogViewController: UICollectionViewController, UITextFieldDelegate {
    
    lazy var inputTextField: UITextField = {
        let inputTextField = UITextField()
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.placeholder = "Enter Message..."
        inputTextField.delegate = self
        return inputTextField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Chat Log Controller"
        collectionView?.backgroundColor = .white
        setupTextView()
    }
    
    func setupTextView() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
            ])
        
        let sendButton = UIButton()
        sendButton.setTitle("Send", for: .normal)
        sendButton.backgroundColor = .red
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        NSLayoutConstraint.activate([
            sendButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 80),
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            sendButton.topAnchor.constraint(equalTo: containerView.topAnchor)
            ])
        sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        
        
        containerView.addSubview(inputTextField)
        NSLayoutConstraint.activate([
            inputTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor),
            inputTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputTextField.topAnchor.constraint(equalTo: containerView.topAnchor)
            ])
        
        let dividerLine = UIView()
        containerView.addSubview(dividerLine)
        dividerLine.backgroundColor = .lightGray
        dividerLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dividerLine.heightAnchor.constraint(equalToConstant: 0.5),
            dividerLine.widthAnchor.constraint(equalTo: view.widthAnchor),
            dividerLine.bottomAnchor.constraint(equalTo: containerView.topAnchor)
            ])
    }
    
    @objc func handleSendMessage() {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let values = ["text": inputTextField.text]
        childRef.updateChildValues(values as! [String : String])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
}
