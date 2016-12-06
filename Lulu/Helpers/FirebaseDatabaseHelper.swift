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
        
        if let chats = snap.childSnapshot(forPath: "chats").value as? [String: Any] {
            seller.chats = Array(chats.keys)
        }
        
        completion(seller)
    })
}

/**
 Gets a Chat by its UID. Completion with nil if it doesn't exist in the database.
 */
func getChatById(_ chatId: String, completion: @escaping (Chat?) -> Void) {
    let ref = FIRDatabase.database().reference()
    
    ref.child("chats/\(chatId)").observeSingleEvent(of: .value, with: { (chatSnapshot) in
        // Ensure that chat exists.
        guard chatSnapshot.exists() else {
            completion(nil)
            return
        }
        
        // Convert chat data to Chat object.
        if let chatData = chatSnapshot.value as? [String: Any] {
            let listingId = chatData["listingId"] as! String // Required values.
            let title = chatData["title"] as! String
            let lastMessage = chatData["lastMessage"] as! String
            let createdTimestamp = chatData["createdTimestamp"] as! Int

            completion(Chat(uid: chatId, listingUid: listingId, title: title, lastMessage: lastMessage, createdTimestamp: createdTimestamp))
        }
    })
}

/**
 Writes a chat message to the database.
 
 - parameter chatId: UID of the chat this message is associated with.
 - parameter senderId: UID of the user who sent this message.
 - parameter messageText: Text of the message.
 */
func writeChatMessage(chatId: String, senderId: String, messageText: String) {
    let chatMessageRef = FIRDatabase.database().reference().child("messages/\(chatId)").childByAutoId()
    
    let message: [String: Any] = [
        "senderUid": senderId,
        "text": messageText,
        "createdTimestamp": FIRServerValue.timestamp()
    ]
    
    chatMessageRef.setValue(message)
    updateChatLastMessage(chatId: chatId, messageText: messageText)
}

/**
 Updates the lastMessage of the Chat with chat ID.
 
 - parameter chatId: UID of the chat to update.
 - parameter messageText: Message text to update the Chat with.
 */
func updateChatLastMessage(chatId: String, messageText: String) {
    let chatRef = FIRDatabase.database().reference().child("chats/\(chatId)/lastMessage")
    chatRef.setValue(messageText)
}

/**
 Writes the chat to the database. Adds chat to seller's and bidder's chats
 
 - parameter listingId: Dictionary with listing information.
 - parameter sellerId: Seller's user ID.
 - parameter bidderId: Bidder's user ID.
 - parameter completion: Completion block to pass the new Chat to.
 */
func writeChat(listingId: String, sellerId: String, bidderId: String, withTitle title: String, completion: @escaping (Chat?) -> Void) {
    let ref = FIRDatabase.database().reference()
    let chatRef = ref.child("chats").childByAutoId()
    let chat: [String: Any] = [
        "listingId": listingId,
        "title": title,
        "lastMessage": "",
        "createdTimestamp": FIRServerValue.timestamp()
    ]
    
    // Update seller chats to have a reference to the new chat.
    writeUserChat(userId: sellerId, chatId: chatRef.key)
    
    // Update buyer chats to have a reference to the new chat.
    writeUserChat(userId: bidderId, chatId: chatRef.key)
    
    // Update listing bidder chats to have a reference from buyer
    writeListingBidderChat(listingId: listingId, bidderId: bidderId, chatId: chatRef.key)

    // Write chat to database.
    chatRef.setValue(chat) { (error, newChatRef) in
        if error != nil {
            // TODO: Handle error.
            return
        }

        getChatById(chatRef.key, completion: completion)
    }
}

/**
 Writes the chat as part of the user's chats in the database
 */
func writeUserChat(userId: String, chatId: String) {
    let userChatsRef = FIRDatabase.database().reference().child("users/\(userId)/chats/\(chatId)")
    userChatsRef.setValue(true) { (error, _) in
        if error != nil {
            // TODO: Handle error.
            return
        }
    }
}

/**
 Writes the chat as part of the listing's bidder chats. Maps bidder ID to the chat ID for the listing.
 */
func writeListingBidderChat(listingId: String, bidderId: String, chatId: String) {
    let listingBidderChatsRef = FIRDatabase.database().reference().child("listings/\(listingId)/bidderChats/\(bidderId)")
    listingBidderChatsRef.setValue(chatId) { (error, _) in
        if error != nil {
            // TODO: Handle error.
            return
        }
    }
}
