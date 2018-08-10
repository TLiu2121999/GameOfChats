//
//  LoginViewController+handlers.swift
//  GameOfChats
//
//  Created by Tongtong Liu on 7/26/18.
//  Copyright © 2018 Tongtong Liu. All rights reserved.
//

import UIKit
import Firebase


extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleLogRegister() {
        if loginRegisterSegmentControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Email and Password can't be nil! ")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error != nil {
                return
            }
            self.messagesViewController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: nil)
            print("Login Succeed!")
        }
    }
    
    @objc func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Name and Password can't be nil! ")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            (authResult, error) in
            if error != nil {
                return
            }
            guard let uid = authResult?.user.uid else { return }
            
            let imageName = UUID().uuidString
            let storageRef = Storage.storage().reference().child("\(imageName).jpg")
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                    if error != nil {
                        return
                    } else {
                        storageRef.downloadURL(completion: { (url, error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            if url != nil {
                                let values = ["name": name, "email": email, "profileIamgeURL": url!.absoluteString]
                                self.registerUserIntoDatabase(uid: uid, values: values)
                            }
                        })
                    }
                })
            }
        })
    }
    
    private func registerUserIntoDatabase(uid: String, values: [String: Any]) {
        let ref = Database.database().reference()
        let usersRed = ref.child("users").child(uid)
        usersRed.updateChildValues(values as [AnyHashable : Any], withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            self.messagesViewController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: nil)
            print("Registration Succeed!")
        })
    }
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentControl.titleForSegment(at: loginRegisterSegmentControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        // set up whole input container height
        inputContainerViewHeightConstraint?.constant = loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 100 : 150
        
        // set up nameTextField
        nameTextFieldHeightAnchorConstraint?.isActive = false
        nameTextFieldHeightAnchorConstraint = loginRegisterSegmentControl.selectedSegmentIndex == 0 ? nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 0) : nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchorConstraint?.isActive = true
        
        // set up emailTextField
        emailTextFieldHeightAnchorConstraint?.isActive = false
        emailTextFieldHeightAnchorConstraint = loginRegisterSegmentControl.selectedSegmentIndex == 0 ? emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/2) : emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchorConstraint?.isActive = true
        
        // set up passwordTextField
        passwordTextFieldHeightAnchorConstraint?.isActive = false
        passwordTextFieldHeightAnchorConstraint = loginRegisterSegmentControl.selectedSegmentIndex == 0 ? passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/2) : passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchorConstraint?.isActive = true
    }
    
    
    @objc func handleSelectProfileIamgeView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        
        if let edittedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = edittedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        
        profileImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        print("Did Cancel!")
    }
}
