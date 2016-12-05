//
//  ChatListViewController.swift
//  Lulu
//
//  Created by Jan Clarin on 12/3/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseAuth

final class ChatListViewController: UITableViewController {
    
    // MARK: - Properties
    let cellIdentifier = "ChatCell"
    var chats: [Chat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let loggedInUserId = FIRAuth.auth()?.currentUser?.uid else {
            // Not logged in, so no user chats. Don't load anything.
            // TODO: Prompt log in.
            return
        }
        
        // Get every chat from the user and display them.
        getUserById(userId: loggedInUserId) { (user) in
            for chatId in user.chats {
                getChatById(chatId) { (chat) in
                    if let chat = chat {
                        self.chats.append(chat)
                    }
                    self.tableView.reloadData()
                }
            }
        }

    }
    
    // MARK: UITTableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as UITableViewCell
        
        let chat = chats[indexPath.row]
        
        cell.textLabel?.text = chat.listingUid
        
        return cell
    }
}
