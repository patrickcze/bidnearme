//
//  Group.swift
//  Lulu
//
//  Created by Patrick Czeczko on 2016-12-03.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class Group {
    var id: String
    var name: String
    var desc: String
    var createdTimestamp: Int
    var memberIds: [String]
    var listingIds: [String]
    var imageUrl: URL
    
    init(id: String, name: String, desc: String, createdTimestamp: Int, members: [String], listings: [String], imageUrl: URL) {
        self.id = id
        self.name = name
        self.desc = desc
        self.createdTimestamp = createdTimestamp
        self.memberIds = members
        self.listingIds = listings
        self.imageUrl = imageUrl
    }
}
