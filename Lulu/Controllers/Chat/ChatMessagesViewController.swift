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
    var messages = [Message]()
    var jsqMessages = [JSQMessage]()
    var chat: Chat? {
        didSet {
            title = chat?.title
        }
    }
    
    private lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    private lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let chatId = chat?.uid else {
            return
        }

        // Pull messages for the chat. Watch for new messages after.
        populateMessages(chatId: chatId) {
            // Watch for new messages in the chat.
            self.observeMessages(chatId: chatId)
        }
        
        // Remove avatars from messages.
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // Remove media attachment icon.
        inputToolbar.contentView.leftBarButtonItem = nil
    }

    
    /**
     Adds messages to JSQMessages.
     Message's displayName (user's name) is not being used at the moment.
     */
    private func addMessage(_ message: Message) {
        jsqMessages.append(JSQMessage(senderId: message.senderUid, displayName: "", text: message.text))
    }
    
    /**
     Pulls messages from the database for this chat and adds them to the list.
     */
    private func populateMessages(chatId: String, completion: @escaping () -> Void) {
        getMessagesByChatId(chatId) { (messages) in
            self.messages = messages
            // Add every message to JSQMessages.
            for message in messages {
                self.addMessage(message)
            }
            
            self.finishReceivingMessage()
            completion()
        }
    }
    
    /**
     Sets observer to listen for new messages and adds them to the list.
     */
    private func observeMessages(chatId: String) {
        let chatMessagesRef = FIRDatabase.database().reference().child("messages/\(chatId)")
        
        // Observe for new messages from reference to chat's messages.
        chatMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageUid = snapshot.key
            let messageData = snapshot.value as! [String: Any]
            
            let senderUid = messageData["senderUid"] as! String
            let text = messageData["text"] as! String
            let createdTimestamp = messageData["createdTimestamp"] as! Int
            
            self.addMessage(Message(uid: messageUid, senderUid: senderUid, text: text, createdTimestamp: createdTimestamp))
            self.finishReceivingMessage()
        })
    }
    
    /**
     Sets up outgoing bubble image for UI.
     */
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    /**
     Sets up incoming bubble image for UI.
     */
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    // MARK: - JSQMessagesViewController
    // Respond to send button press.
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        guard let chatId = chat?.uid else {
            return
        }
        
        writeChatMessage(chatId: chatId, senderId: senderId, messageText: text)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    
    // Get JSQMessage for the index.
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData {
        return jsqMessages[indexPath.item]
    }
    
    // Determine which bubble image view to use depending on who sent the message.
    override func collectionView(_ collectionView: UICollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource {
        let message = jsqMessages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    // Set message bubble text color based on message sender.
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = jsqMessages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    // Remove avatars.
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jsqMessages.count
    }
}
