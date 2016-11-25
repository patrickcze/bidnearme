//
//  Listing.swift
//  Lulu
//
//  Created by Scott Campbell on 10/30/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class Listing {
    
    // MARK: - Properties
    var listingID: String!
    var photos: [URL]!
    var title: String!
    var description: String!
    
    var startPrice: Double!
    var currentPrice: Int!
    var buyoutPrice: Int!
    
    var startDate: String!
    var endDate: String!
    
    var seller: User!
    var bidders: [User]!
    var favorited: [User]!
    
    var winningBid: Bid! // ronny: I need this for profile
    
    // Listing initialization.
    init(_ id:String, _ photos: [URL], _ title: String, _ description: String, _ startPrice: Double, _ buyoutPrice: Int, _ startDate: String, _ endDate: String, _ seller: User) {
        self.listingID = id
        self.photos = photos
        self.title = title
        self.description = description
        self.startPrice = startPrice
        self.buyoutPrice = buyoutPrice
        self.startDate = startDate
        self.endDate = endDate
        self.seller = seller
    }
}
