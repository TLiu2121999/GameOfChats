//
//  UserCell.swift
//  GameOfChats
//
//  Created by Tongtong Liu on 8/17/18.
//  Copyright © 2018 Tongtong Liu. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    var message: Message? {
        didSet {
            setupNameAndProfileImage()
            
            self.detailTextLabel?.text = message?.text
            
            guard let timeStr = message?.timeStamp else { return }
            let timeDate = NSDate(timeIntervalSince1970: Double(timeStr)!)
            let dataFormatter = DateFormatter()
            dataFormatter.dateFormat = "hh:mm:ss a"
            timeLabel.text = dataFormatter.string(from: timeDate as Date)
        }
    }
    
    private func setupNameAndProfileImage() {
        
        if let userId = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(userId)
            ref.observe(.value) { (dataSnapshot) in
                if let dict = dataSnapshot.value as? [String: Any] {
                    let user = User()
                    user.email = dict["email"] as? String
                    user.name = dict["name"] as? String
                    user.profileImageURL = dict["profileIamgeURL"] as? String
                    
                    self.textLabel?.text = user.name
                    if let profileImageURL = user.profileImageURL {
                        self.profileImageView.loadImageUsingCacheWithURLString(urlString: profileImageURL)
                    }
                }
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let timeLable = UILabel()
        timeLable.font = UIFont.systemFont(ofSize: 12)
        timeLable.textColor = .lightGray
        timeLable.translatesAutoresizingMaskIntoConstraints = false
        return timeLable
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                profileImageView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 8),
                profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                profileImageView.widthAnchor.constraint(equalToConstant: 48),
                profileImageView.heightAnchor.constraint(equalToConstant: 48),
                timeLabel.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -8),
                timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
                timeLabel.widthAnchor.constraint(equalToConstant: 100),
                timeLabel.heightAnchor.constraint(equalTo: self.textLabel!.heightAnchor)
                ])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y, width: frame.width - 72, height: detailTextLabel!.frame.height)
    }
}
