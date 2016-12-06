//
//  Message.swift
//  Lulu
//
//  Created by Jan Clarin on 12/3/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import Foundation

class Message {
    
    // MARK: - Properties
    let uid: String
    let senderUid: String
    let text: String
    let createdTimestamp: Int
    
    init(uid: String, senderUid: String, text: String, createdTimestamp: Int) {
        self.uid = uid
        self.senderUid = senderUid
        self.text = text
        self.createdTimestamp = createdTimestamp
    }
    
    convenience init() {
        self.init(uid: "", senderUid: "", text: "", createdTimestamp: 0)
    }
}
