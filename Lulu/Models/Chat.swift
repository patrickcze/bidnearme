//
//  Chat.swift
//  Lulu
//
//  Created by Jan Clarin on 12/3/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import Foundation

class Chat {
    
    // MARK: - Properties
    let uid: String
    let listingUid: String
    let lastMessage: String
    let createdTimeStamp: Int
    
    init(uid: String, listingUid: String, lastMessage: String, createdTimestamp: Int) {
        self.uid = uid
        self.listingUid = listingUid
        self.lastMessage = lastMessage
        self.createdTimeStamp = createdTimestamp
    }
    
    convenience init() {
        self.init(uid: "", listingUid: "", lastMessage: "", createdTimestamp: 0)
    }
}
