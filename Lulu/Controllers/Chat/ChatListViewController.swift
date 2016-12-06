//
//  ChatListViewController.swift
//  Lulu
//
//  Created by Jan Clarin on 12/3/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

final class ChatListViewController: UITableViewController {
    
    // MARK: - Properties
    let cellIdentifier = "ChatCell"
    var chats = [Chat]()
    var loggedInUser: FIRUser?
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()

        // Get every chat from the user and display them. Observes for new chats.
        observeUserChatList()
    }
    
    /**
     Adds a chat to the list.
     */
    private func addChat(_ chat: Chat) {
        chats.append(chat)
        tableView.reloadData()
    }
    
    /**
     Gets and observes the list of chats for new chats.
     */
    private func observeUserChatList() {
        guard let loggedInUserId = FIRAuth.auth()?.currentUser?.uid else {
            // Not logged in, so no user chats. Don't load anything.
            // TODO: Prompt log in.
            return
        }
        
        let userChatsRef = ref.child("users/\(loggedInUserId)/chats")
        userChatsRef.observe(.childAdded, with: { (userChatSnapshot) in
            let userChatId = userChatSnapshot.key
            getChatById(userChatId) { (chat) in
                if let chat = chat {
                    self.addChat(chat)
                }
            }
        })
    }
    
    // MARK: - UITTableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = chats[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as UITableViewCell
        cell.textLabel?.text = chat.title
        cell.detailTextLabel?.text = chat.lastMessage
        
        return cell
    }
    
    /**
     Segue to ChatMessagesViewController when a chat is selected.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedChat = chats[indexPath.row]
        self.performSegue(withIdentifier: "ShowChatMessages", sender: selectedChat)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let loggedInUser = FIRAuth.auth()?.currentUser else {
            // Not logged in, so no user chats. Don't load anything.
            // TODO: Prompt log in.
            return
        }
        
        if segue.identifier == "ShowChatMessages" {
            if let chat = sender as? Chat {
                let chatMessagesViewController = segue.destination as! ChatMessagesViewController
                chatMessagesViewController.senderId = loggedInUser.uid
                chatMessagesViewController.senderDisplayName = loggedInUser.displayName
                chatMessagesViewController.chat = chat
            }
        }
    }
}
