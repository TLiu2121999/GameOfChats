//
//  Message.swift
//  GameOfChats
//
//  Created by Tongtong Liu on 8/10/18.
//  Copyright © 2018 Tongtong Liu. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {

    var fromId: String?
    var toId: String?
    var timeStamp: String!
    var text: String?
    var imageURL: String?
    
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    func chatPartnerId() -> String? {
        if fromId == Auth.auth().currentUser?.uid {
            return toId
        } else {
            return fromId
        }
    }
}
