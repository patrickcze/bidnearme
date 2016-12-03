//
//  Bid.swift
//  Lulu
//
//  Created by Patrick Czeczko on 2016-12-02.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class Bid {
    
    // MARK: - Properties
    var bidId: String!
    var bidderId: String!
    var amount: Double!
    let createdTimestamp: Int!
    
    init(bidId: String, bidderId: String, amount: Double, createdTimestamp: Int) {
        self.bidId = bidId
        self.bidderId = bidderId
        self.amount = amount
        self.createdTimestamp = createdTimestamp
    }
}
