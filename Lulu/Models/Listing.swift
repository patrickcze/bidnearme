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
    var listingId: String!
    var sellerId: String!
    var title: String!
    var description: String?
    var startPrice: Double!
    var currencyCode: CurrencyCode?
    var createdTimestamp: Int!
    var auctionEndTimestamp: Int!
    var winningBidId: String!
    var bidsById: [String: Bid]?
    var imageUrls: [URL]!
    var buyoutPrice: Double?
    var winningBid: Bid!
    var bidderChats: [String: String]! // Maps bidder IDs to chat IDs.
    var longitude: Double?
    var latitude: Double?
    
    // Listing initialization.
    init(listingId:String,  sellerId: String ,  imageUrls: [URL],  title: String,  description: String,  startPrice: Double,  buyoutPrice: Double,  currencyCode: CurrencyCode,  createdTimestamp: Int,  auctionEndTimestamp: Int,  winningBidId: String,  bids: [String: Bid], bidderChats: [String: String]) {
        self.listingId = listingId
        self.imageUrls = imageUrls
        self.title = title
        self.description = description
        self.startPrice = startPrice
        self.buyoutPrice = buyoutPrice
        self.sellerId = sellerId
        self.currencyCode = currencyCode
        self.createdTimestamp = createdTimestamp
        self.auctionEndTimestamp = auctionEndTimestamp
        self.winningBidId = winningBidId
        self.bidsById = bids
        self.bidderChats = bidderChats
    }
    
    // Listing initialization.
    init(listingId:String,  sellerId: String ,  imageUrls: [URL],  title: String,  description: String,  startPrice: Double,  buyoutPrice: Double,  currencyCode: CurrencyCode,  createdTimestamp: Int,  auctionEndTimestamp: Int,  winningBidId: String,  bids: [String: Bid], bidderChats: [String: String], longitude: Double, latitude: Double) {
        self.listingId = listingId
        self.imageUrls = imageUrls
        self.title = title
        self.description = description
        self.startPrice = startPrice
        self.buyoutPrice = buyoutPrice
        self.sellerId = sellerId
        self.currencyCode = currencyCode
        self.createdTimestamp = createdTimestamp
        self.auctionEndTimestamp = auctionEndTimestamp
        self.winningBidId = winningBidId
        self.bidsById = bids
        self.bidderChats = bidderChats
        self.latitude = latitude
        self.longitude = longitude
    }
}
