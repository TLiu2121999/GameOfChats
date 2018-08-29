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
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid).child(toId)
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
                    
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                    
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 58, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(8, 0, 58, 0)
        collectionView?.keyboardDismissMode = .interactive
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setupTextView()
        setupKeyboardObservers()
    }
    
    
    //=============================================================================
    /*
     lazy var inputContainerView: UIView = {
     
     let containerView = UIView()
     containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
     containerView.backgroundColor = UIColor.white
     
     let sendButton = UIButton(type: .system)
     sendButton.setTitle("Send", for: UIControlState())
     sendButton.translatesAutoresizingMaskIntoConstraints = false
     sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
     containerView.addSubview(sendButton)
     
     NSLayoutConstraint.activate([
     sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor),
     sendButton.widthAnchor.constraint(equalToConstant: 80),
     sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor),
     sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
     ])
     
     containerView.addSubview(inputTextField)
     NSLayoutConstraint.activate([
     inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8),
     inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor),
     inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
     inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor)
     ])
     
     let dividerLine = UIView()
     containerView.addSubview(dividerLine)
     dividerLine.backgroundColor = .lightGray
     dividerLine.translatesAutoresizingMaskIntoConstraints = false
     NSLayoutConstraint.activate([
     dividerLine.heightAnchor.constraint(equalToConstant: 0.5),
     dividerLine.widthAnchor.constraint(equalTo: containerView.widthAnchor),
     dividerLine.bottomAnchor.constraint(equalTo: containerView.topAnchor)
     ])
     
     return containerView
     }()
     
     override var inputAccessoryView: UIView? {
     get {
     return inputContainerView
     }
     }
     
     override var canBecomeFirstResponder : Bool {
     return true
     }
     */
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func dismissKeyboard() {
        inputTextField.resignFirstResponder()
    }
    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    @objc func handleKeyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let keyboardDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        containerViewBottomAnchor?.constant = -keyboardFrame.height + view.safeAreaInsets.bottom
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
            let _ = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        cell.bubbleViewWidthAnchor?.constant = estimateFrameForText(text: cell.textView.text).width + 32
        setupCell(cell: cell, messgae: message)
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, messgae: Message) {
        if let profileImageUrl = self.user?.profileImageURL {
            cell.profileImageView.loadImageUsingCacheWithURLString(urlString: profileImageUrl)
        }
        
        if Auth.auth().currentUser?.uid == messgae.fromId{
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = ChatMessageCell.grayColor
            cell.textView.textColor = .black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
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
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    
    func setupTextView() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            containerViewBottomAnchor!,
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 50)
            ])
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        NSLayoutConstraint.activate([
            sendButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 80),
            sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor),
            sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
        sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        
        
        containerView.addSubview(inputTextField)
        NSLayoutConstraint.activate([
            inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8),
            inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor),
            inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor)
            ])
        
        let dividerLine = UIView()
        containerView.addSubview(dividerLine)
        dividerLine.backgroundColor = .lightGray
        dividerLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dividerLine.heightAnchor.constraint(equalToConstant: 0.5),
            dividerLine.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            dividerLine.bottomAnchor.constraint(equalTo: containerView.topAnchor)
            ])
    }
    
    @objc func handleSendMessage() {
        if inputTextField.text == "" { return }
        
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
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessageRef.updateChildValues([messageId: 1])
        }
        inputTextField.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
}
