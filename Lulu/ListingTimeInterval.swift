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
    case sevenDays = 7
    case tenDays = 10
    case fourteenDays = 14
    //static var count: Int{return ListingTimeInterval.fourteenDays.hashValue +1}
    //static var count: Int { return ListingTimeInterval.fourteenDays.hashValue + 1 }
    static let allValues = [oneDay, threeDays, fiveDays, sevenDays, tenDays, fourteenDays]
    
    var description: String {
        switch self {
        case .oneDay: return "1 Day"
        default: return "\(self.rawValue) Days"
        }
    }
    
    var numberOfMilliseconds: Int {
        let millisecondsPerDay = 86400000
        return self.rawValue * millisecondsPerDay
    }
}
