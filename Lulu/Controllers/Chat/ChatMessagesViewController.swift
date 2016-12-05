//
//  ChatMessagesViewController.swift
//  Lulu
//
//  Created by Jan Clarin on 12/5/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import Firebase
import JSQMessagesViewController

final class ChatMessagesViewController: JSQMessagesViewController {
    
    // MARK: - Properties
    var chat: Chat? {
        didSet {
            title = chat?.listingUid
        }
    }
}
