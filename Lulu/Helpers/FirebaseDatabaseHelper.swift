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
            let lastMessage = chatData["lastMessage"] as! String
            let createdTimestamp = chatData["createdTimestamp"] as! Int

            completion(Chat(uid: chatId, listingUid: listingId, lastMessage: lastMessage, createdTimestamp: createdTimestamp))
        }
    })
}

/**
 Gets a chat Messages by the chat UID. Completion with an empty if there are no messages for the chat in the database.
 */
func getMessagesByChatId(_ chatId: String, completion: @escaping([Message]) -> Void) {
    let ref = FIRDatabase.database().reference()
    
    ref.child("messages/\(chatId)").observeSingleEvent(of: .value, with: { (messagesSnapshot) in
        guard messagesSnapshot.exists(), messagesSnapshot.hasChildren() else {
            completion([])
            return
        }
        
        if let messagesData = messagesSnapshot.value as? [String: Any] {
            var messages: [Message] = []
            for messageId in messagesData.keys {
                let messageData = messagesData[messageId] as! [String: Any]
                let senderId = messageData["senderId"] as! String
                let text = messageData["text"] as! String
                let createdTimestamp = messageData["createdTimestamp"] as! Int
                messages.append(Message(id: messageId, senderUid: senderId, text: text, createdTimestamp: createdTimestamp))
            }
            completion(messages)
        }
    })
}

/**
 Writes the chat to the database. Adds chat to seller's and bidder's chats
 
 - parameter listingId: Dictionary with listing information.
 - parameter sellerId: Seller's user ID.
 - parameter bidderId: Bidder's user ID.
 - parameter completion: Completion block to pass the new Chat to.
 */
func writeChat(listingId: String, sellerId: String, bidderId: String, completion: @escaping (Chat) -> Void) {
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
    writeUserChat(userId: bidderId, chatId: chatRef.key)
    
    // Update listing bidder chats to have a reference from buyer
    writeListingBidderChat(listingId: listingId, bidderId: bidderId, chatId: chatRef.key)

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

/**
 Writes the chat as part of the user's chats in the database
 */
func writeUserChat(userId: String, chatId: String) {
    let userChatsRef = FIRDatabase.database().reference().child("users/\(userId)/chats/\(chatId)")
    userChatsRef.setValue(true) { (error, _) in
        guard let _ = error else {
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
        guard let _ = error else {
            // TODO: Handle error.
            return
        }
    }
}
