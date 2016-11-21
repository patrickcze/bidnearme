//
//  ListingTimeInterval.swift
//  Lulu
//
//  Created by Jan Clarin on 11/20/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

enum ListingTimeInterval: Int {
    case oneDay = 1
    case threeDays = 3
    case fiveDays = 5
    case tenDays = 10
    case oneWeek = 7
    case twoWeeks = 14
    
    var numberOfMilliseconds: Int {
        let millisecondsPerDay = 86400000
        return self.rawValue * millisecondsPerDay
    }
}
