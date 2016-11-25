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
    var amount : Double!
    var createdTimestamp : Int!
    var bidderId : String!
    
    // Bid initialization.
    init(_ amount : Double, _ bidderId: String, _ createdTimestamp : Int) {
        self.amount = amount
        self.createdTimestamp = createdTimestamp
        self.bidderId = bidderId
    }
}
