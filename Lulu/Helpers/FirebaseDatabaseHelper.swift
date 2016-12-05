//
//  FirebaseDatabaseHelper.swift
//  Lulu
//
//  Created by Patrick Czeczko on 2016-12-02.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseDatabase

// This function allows you to get the amount of a given bid
func getListingBidById(listingId: String, bidId: String, completion: @escaping (Bid?) -> Void) {
    let ref = FIRDatabase.database().reference()
    
    ref.child("listings/\(listingId)/bids/\(bidId)").observeSingleEvent(of: .value, with: { snap in
        let bidData = snap.value as? [String: Any]
        
        let bid = Bid(bidId: bidId, bidderId: bidData?["bidderId"] as! String, amount: bidData?["amount"] as! Double, createdTimestamp: bidData?["createdTimestamp"] as! Int)
        completion(bid)
    })
}

// This function allows you to obatin user object with details simply from the userID
func getUserById (userId: String, completion: @escaping (User) -> Void) {
    let ref = FIRDatabase.database().reference()
    
    ref.child("users/\(userId)").observeSingleEvent(of: .value, with: { snap in
        guard let userProfileImageUrlString = snap.childSnapshot(forPath: "profileImageUrl").value as? String else {
            // TODO: Deal with missing profile image
            return
        }
        
        let userProfileImageUrl = URL(string: userProfileImageUrlString)
        let sellerName = snap.childSnapshot(forPath: "name").value as? String
        let timestamp = snap.childSnapshot(forPath: "createdTimestamp").value as? Int
        
        let seller = User(uid: userId, name: sellerName!, profileImageUrl: userProfileImageUrl, createdTimestamp: timestamp!)
        
        completion(seller)
    })
}

func getChatById(chatId: String, completion: @escaping (Chat) -> Void) {
    let chat = Chat()
    completion(chat)
}

func getChatMessagesById(chatId: String, completion: @escaping([Message]) -> Void) {
}

/**
 Writes the chat to the database. Adds chat to seller's and buyer's chats
 
 - parameter listingId: Dictionary with listing information.
 - parameter sellerId: Seller's user ID.
 - parameter buyerId: Buyer's user ID.
 - parameter completion: Completion block to pass the new Chat to.
 */
func writeChat(listingId: String, sellerId: String, buyerId: String, completion: @escaping (Chat) -> Void) {
    let ref = FIRDatabase.database().reference()
    let chatRef = ref.child("chats").childByAutoId()
    let chat: [String: Any] = [
        "listingId": listingId,
        "lastMessage": "",
        "createdTimestamp": FIRServerValue.timestamp()
    ]
    
    // Update seller chats to have a reference to the new chat.
    writeUserChat(userId: sellerId, chatId: chatRef.key)
    
    // Update buyer chats to have a reference to the new chat.
    writeUserChat(userId: buyerId, chatId: chatRef.key)

    // Write chat to database.
    chatRef.setValue(chat) { (error, newChatRef) in
        guard let _ = error,
            let newChatTimestamp = newChatRef.value(forKey: "createdTimestamp") as? Int else {
            // TODO: Handle error.
            return
        }
        
        completion(Chat(uid: newChatRef.key, listingUid: listingId, lastMessage: "", createdTimestamp: newChatTimestamp))
    }
}

func writeUserChat(userId: String, chatId: String) {
    let userChatsRef = FIRDatabase.database().reference().child("users/\(userId)/chats")
    
    userChatsRef.setValue([chatId: true]) { (error, _) in
        // TODO: Handle error.
    }
}
