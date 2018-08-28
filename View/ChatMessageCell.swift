//
//  ChatMessageCell.swift
//  GameOfChats
//
//  Created by Tongtong Liu on 8/28/18.
//  Copyright © 2018 Tongtong Liu. All rights reserved.
//

import UIKit
class ChatMessageCell: UICollectionViewCell {
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let bubbleView: UIView = {
       let bubbleView = UIView()
        bubbleView.backgroundColor = UIColor(r: 0, g: 134, b: 249)
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.masksToBounds = true
        return bubbleView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        NSLayoutConstraint.activate([
            bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
            bubbleView.topAnchor.constraint(equalTo: self.topAnchor),
            bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor),
            bubbleViewWidthAnchor!,
            
            textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8),
            textView.topAnchor.constraint(equalTo: self.topAnchor),
            textView.heightAnchor.constraint(equalTo: self.heightAnchor),
            textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor)
        ])
    }
}
