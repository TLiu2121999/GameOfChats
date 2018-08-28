//
//  ChatLogViewController.swift
//  GameOfChats
//
//  Created by Tongtong Liu on 8/9/18.
//  Copyright © 2018 Tongtong Liu. All rights reserved.
//

import WebKit
import Firebase

class ChatLogViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    let cellId = "cellId"
    var messages = [Message]()
    lazy var inputTextField: UITextField = {
        let inputTextField = UITextField()
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.placeholder = "Enter Message..."
        inputTextField.delegate = self
        return inputTextField
    }()
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: String] {
                    let message = Message()
                    message.fromId = dict["fromId"]
                    message.toId = dict["toId"]
                    message.text = dict["text"]
                    message.timeStamp = dict["timeStamp"]
                    
                    if message.chatPartnerId() == self.user?.id {
                        self.messages.append(message)
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 58, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(8, 0, 58, 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.textView.text = messages[indexPath.row].text
        cell.bubbleViewWidthAnchor?.constant = estimateFrameForText(text: cell.textView.text).width + 32
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        if let text = messages[indexPath.row].text {
            height = estimateFrameForText(text: text).height + 20
        }
        let frame = view.frame
        return CGSize(width: frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 100)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
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
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
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
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp: String = String(Int(NSDate().timeIntervalSince1970))
        let values : [String : Any] = ["text" : inputTextField.text, "toId" : toId, "fromId" : fromId, "timeStamp" : timeStamp]

        childRef.updateChildValues(values as! [String : String]) { (error, red) in
            if error != nil {
                return
            }
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId)
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId)
            recipientUserMessageRef.updateChildValues([messageId: 1])
        }
        inputTextField.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
}
