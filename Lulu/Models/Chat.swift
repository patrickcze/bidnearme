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
    let title: String
    var lastMessage: String // Can be modified when a new message is entered.
    let createdTimeStamp: Int
    
    init(uid: String, listingUid: String, title: String, lastMessage: String, createdTimestamp: Int) {
        self.uid = uid
        self.listingUid = listingUid
        self.title = title
        self.lastMessage = lastMessage
        self.createdTimeStamp = createdTimestamp
    }
    
    convenience init() {
        self.init(uid: "", listingUid: "", title: "", lastMessage: "", createdTimestamp: 0)
    }
}
