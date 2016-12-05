//
//  ChatListViewController.swift
//  Lulu
//
//  Created by Jan Clarin on 12/3/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

final class ChatListViewController: UITableViewController {
    
    // MARK: - Properties
    let cellIdentifier = "ChatCell"
    var chatList: [Chat] = []
    var loggedInUser: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getChatById(chatId: "") { (chat) in
            self.chatList.append(chat)
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: UITTableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as UITableViewCell
        
        let chat = chatList[indexPath.row]
        
        cell.textLabel?.text = "HELLO" //chat.listingUid
        
        return cell
    }
}
