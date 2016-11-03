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
    var photos: [UIImage]!
    var title: String!
    var description: String!
    
    var startPrice: Int!
    var currentPrice: Int!
    var buyoutPrice: Int!
    
    var startDate: String!
    var endDate: String!
    
    var seller: User!
    var bidders: [User]!
    var favorited: [User]!
    
    // Listing initialization.
    init(_ id:String, _ photos: [UIImage], _ title: String, _ description: String, _ startPrice: Int, _ buyoutPrice: Int, _ startDate: String, _ endDate: String, _ seller: User) {
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
