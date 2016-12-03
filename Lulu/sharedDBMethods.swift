//
//  sharedDBMethods.swift
//  Lulu
//
//  Created by Patrick Czeczko on 2016-12-02.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseDatabase

// This function allows you to get the amount of a given bid
func getBidAmountFromBidID(listingId: String, bidId: String, completion: @escaping (Double?) -> Void) {
    let storageRef = FIRDatabase.database().reference()
    
    storageRef.child("listings/\(listingId)/bids/\(bidId)").observeSingleEvent(of: .value, with: { snap in
        if let amount = snap.childSnapshot(forPath: "amount").value as? Double {
            completion(amount)
        }
    })
}

func getBidObjectFromBidID(listingId: String, bidId: String, completion: @escaping (Bid?) -> Void) {
    let ref = FIRDatabase.database().reference()
    
    ref.child("listings/\(listingId)/bids/\(bidId)").observeSingleEvent(of: .value, with: { snap in
        let bidData = snap.value as? [String: Any]
        
        let bid = Bid(bidId: bidId, bidderId: bidData?["bidderId"] as! String, amount: bidData?["amount"] as! Double, createdTimestamp: bidData?["createdTimestamp"] as! Int)
        completion(bid)
    })
}


// This function allows you to obatin user object with details simply from the userID
func getUserFromUserID (userId: String, completion: @escaping (User) -> Void) {
    let storageRef = FIRDatabase.database().reference()
    
    storageRef.child("users/\(userId)").observeSingleEvent(of: .value, with: { snap in
        if let userProfileImageUrlString = snap.childSnapshot(forPath: "profileImageUrl").value as? String {
            let userProfileImageUrl = URL(string: userProfileImageUrlString)
            let sellerName = snap.childSnapshot(forPath: "name").value as? String
            let timestamp = snap.childSnapshot(forPath: "createdTimestamp").value as? Int
            
            let seller = User(uid: userId, name: sellerName!, profileImageUrl: userProfileImageUrl, createdTimestamp: timestamp!)
            
            completion(seller)
        }
        else {
            let userProfileImageUrlString = "https://firebasestorage.googleapis.com/v0/b/lulu-c1315.appspot.com/o/listingImages%2Fnophoto.png?alt=media&token=51c25631-529c-4f09-866b-f6aaa34b5f79"
            let userProfileImageUrl = URL(string: userProfileImageUrlString)
            let sellerName = snap.childSnapshot(forPath: "name").value as? String
            let timestamp = snap.childSnapshot(forPath: "createdTimestamp").value as? Int
            
            let seller = User(uid: userId, name: sellerName!, profileImageUrl: userProfileImageUrl, createdTimestamp: timestamp!)
            
            completion(seller)
        }
    })
}

