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
    var UId: String!
    var name: String!
    var profileImageUrl: URL?
    let createdTimestamp: Int!
    var listingIdsByType: [ListingType: [String]]!
    var ratings: [String: Rating]?
    var groups: [String]?
    
    init(UId: String, name: String, profileImageUrl: URL?, createdTimestamp: Int, listingIdsByType: [ListingType: [String]], ratings: [String: Rating], groups: [String]) {
        self.UId = UId
        self.name = name
        self.profileImageUrl = profileImageUrl
        self.createdTimestamp = createdTimestamp
        self.listingIdsByType = listingIdsByType
        self.ratings = ratings
        self.groups = groups
    }
    
    convenience init(UId: String, name: String, profileImageUrl: URL?, createdTimestamp: Int) {
        self.init(UId: UId,name: name, profileImageUrl: profileImageUrl, createdTimestamp: createdTimestamp, listingIdsByType: [:], ratings: [:], groups: [])
    }
    
    convenience init() {
        self.init(UId:"", name: "", profileImageUrl: nil, createdTimestamp: 0, listingIdsByType: [:], ratings: [:], groups: [])
    }
}
