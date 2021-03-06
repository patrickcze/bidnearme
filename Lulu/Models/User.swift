//
//  User.swift
//  Lulu
//
//  Created by Scott Campbell on 10/30/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class User {
    
    // MARK: - Properties
    var uid: String!
    var name: String!
    var profileImageUrl: URL?
    let createdTimestamp: Int! // In Unix Epoch time (milliseconds)
    var listingIdsByType: [ListingType: [String]]!
    var ratingsById: [String: Rating]?
    var groups: [String]?
    var chats: [String]!
    var joinDate: Date!
    
    init(uid: String, name: String, profileImageUrl: URL?, createdTimestamp: Int, listingIdsByType: [ListingType: [String]], ratingsById: [String: Rating], groups: [String], chats: [String]) {
        self.uid = uid
        self.name = name
        self.profileImageUrl = profileImageUrl
        self.createdTimestamp = createdTimestamp
        self.listingIdsByType = listingIdsByType
        self.ratingsById = ratingsById
        self.groups = groups
        self.chats = chats
        self.joinDate = Date(timeIntervalSince1970: TimeInterval(createdTimestamp / 1000))
    }
    
    convenience init(uid: String, name: String, profileImageUrl: URL?, createdTimestamp: Int) {
        self.init(uid: uid,name: name, profileImageUrl: profileImageUrl, createdTimestamp: createdTimestamp, listingIdsByType: [:], ratingsById: [:], groups: [], chats: [])
    }
    
    convenience init() {
        self.init(uid:"", name: "", profileImageUrl: nil, createdTimestamp: 0, listingIdsByType: [:], ratingsById: [:], groups: [], chats: [])
    }
}
