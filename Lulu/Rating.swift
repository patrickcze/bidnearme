//
//  Rating.swift
//  Lulu
//
//  Created by Patrick Czeczko on 2016-12-02.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class Rating {
    
    // MARK: - Properties
    var uid: String!
    var raterID: String!
    var score: Float!
    var feedbaack: String?
    let createdTimestamp: Int!
    
    init(uid: String, raterID: String, score: Float, feedback: String, createdTimestamp: Int) {
        self.uid = uid
        self.raterID = raterID
        self.score = score
        self.feedbaack = feedback
        self.createdTimestamp = createdTimestamp
    }
    
    convenience init() {
        self.init(uid: "", raterID: "", score:0, feedback: "", createdTimestamp: 0)
    }
}
