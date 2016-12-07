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
    var membersById: [String]
    var listingsById: [String]
    var imageUrl: URL
    
    init(id: String, name: String, desc: String, createdTimestamp: Int, members: [String], listings: [String], imageUrl: URL) {
        self.id = id
        self.name = name
        self.desc = desc
        self.createdTimestamp = createdTimestamp
        self.membersById = members
        self.listingsById = listings
        self.imageUrl = imageUrl
    }
}
