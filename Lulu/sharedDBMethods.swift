//
//  sharedDBMethods.swift
//  Lulu
//
//  Created by Patrick Czeczko on 2016-12-02.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseDatabase

func getBidAmountFromBidID(listingId: String, bidId: String, completion: @escaping (Double?) -> Void) {
    let storageRef = FIRDatabase.database().reference()
    
    storageRef.child("listings/\(listingId)/bids/\(bidId)").observeSingleEvent(of: .value, with: { snap in
        if let amount = snap.childSnapshot(forPath: "amount").value as? Double {
            completion(amount)
        }
    })
}

