//
//  ListingType.swift
//  Lulu
//
//  Created by Jan Clarin on 11/22/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

/**
 Supported listing types for users.
 These should match exactly with listing types under users.
 Otherwise, nothing will work.
 */
enum ListingType: String {
    case selling = "selling"
    case sold = "sold"
    case bidding = "bidding"
    case won = "won"
    case lost = "lost"
    case watching = "watching"
    
    static let allValues = [selling, sold, bidding, won, lost, watching]
    
    var description: String {
        return self.rawValue
    }
}
