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
    var profileImageUrl: URL?
    let createdTimestamp: Int!
    var listingIdsByType: [ListingType: [String]]!
    
    init(name: String, profileImageUrl: URL?, createdTimestamp: Int, listingIdsByType: [ListingType: [String]]) {
        self.name = name
        self.profileImageUrl = profileImageUrl
        self.createdTimestamp = createdTimestamp
        self.listingIdsByType = listingIdsByType
    }
    
    init(name: String, profileImageUrl: URL?, createdTimestamp: Int) {
        self.name = name
        self.profileImageUrl = profileImageUrl
        self.createdTimestamp = createdTimestamp
    }
    
    convenience init() {
        self.init(name: "", profileImageUrl: nil, createdTimestamp: 0, listingIdsByType: [:])
    }
}
