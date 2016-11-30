//
//  Bid.swift
//  Lulu
//
//  Created by Ronny on 2016-11-25.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import Foundation

class Bid {
    
    // MARK: - Properties
    let amount : Double!
    let createdTimestamp : Int!
    let bidderId : String!
    
    // Bid initialization.
    init(amount : Double, bidderId: String, createdTimestamp : Int) {
        self.amount = amount
        self.createdTimestamp = createdTimestamp
        self.bidderId = bidderId
    }
}
