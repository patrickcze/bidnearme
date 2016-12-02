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
    var name: String!
    var uid : String!
    var profileImageUrl: URL?
    let createdTimestamp: Int!
    var listingIdsByType: [ListingType: [String]]!
    
    init(uid: String, name: String, profileImageUrl: URL?, createdTimestamp: Int, listingIdsByType: [ListingType: [String]]) {
        self.name = name
        self.profileImageUrl = profileImageUrl
        self.createdTimestamp = createdTimestamp
        self.listingIdsByType = listingIdsByType
        self.uid = uid
    }
    
    convenience init(name: String, profileImageUrl: URL?, createdTimestamp: Int) {
        self.init(name: name, profileImageUrl: profileImageUrl, createdTimestamp: createdTimestamp, listingIdsByType: [:])
    }
    
    convenience init() {
        self.init(uid: "dummyID", name: "", profileImageUrl: nil, createdTimestamp: 0, listingIdsByType: [:])
    }
}
