//
//  NewGroupMembersViewController.swift
//  Lulu
//
//  Created by Patrick Czeczko on 2016-12-05.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class NewGroupMembersViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var newGroupButton: UIButton!
    
    // MARK: - Properties
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var listingPhoto: UIImage!
    var listingTitle: String!
    var listingDescription: String!
    var auctionDurationPicker = UIPickerView()
    
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference()
        
        title = "New Group"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        newGroupButton.layer.cornerRadius = 5.0
        newGroupButton.backgroundColor = ColorPalette.bidBlue
    }
    
    // MARK: - Observers
    
    // Observe NSNotification.Name.UIKeyboardWillShow
    func keyboardWillAppear(notification: NSNotification) {
        let info = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        
        guard let rawFrame = value.cgRectValue else {
            return
        }
        
        let keyboardHeight = view.convert(rawFrame, from: nil).height
    }
    
    // Animate stack view constraints.
    func animateNextButton(_ keyboardHeight: CGFloat) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                self.stackViewHeight.constant = keyboardHeight - 36.0
        },
            completion: nil
        )
    }
    
    // Dismiss textfield keyboard.
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
    // Respond to next button tap.
    @IBAction func newGroupButtonClicked(_ sender: UIButton) {
        dismissKeyboard()
        
        // Disable post button while uploading information
        self.newGroupButton.isEnabled = false
        
        print("Creating new group")
        
        guard let currentUserId = FIRAuth.auth()?.currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        guard let title = listingTitle, let description = listingDescription, let image = listingPhoto else {
            print("Missing Details")
            return
        }
        
        // Upload the image and write the listing if the image was successfully uploaded.
        uploadImage(image: image) { (imageUrl) in
            
            guard let imageUrlString = imageUrl?.absoluteString else {
                return
            }
            
            let group: [String: Any] = [
                "name": title,
                "description": description,
                "groupImageUrl": imageUrlString,
                "createdTimestamp": FIRServerValue.timestamp(), // Firebase replaces this with its timestamp.
                "members": [
                    currentUserId: true
                ],
                "listings": []
            ]
            
            // TODO: Allow user input for auction duration.
            self.writeListing(group) { (listingRef) in
                self.addGroupToUsersGroup(groupId: listingRef.key, userId: currentUserId)
                self.performSegue(withIdentifier: "UnwindToRoot", sender: self)
            }
        }
    }
    
    /**
     Calculates a new timestamp based on the duration from an initial timestamp.
     
     - parameter time: Time interval to apply to the initial timestamp.
     - parameter from: Initial timestamp to add the time to.
     */
    func getLaterTimestamp(time: ListingTimeInterval, from initialTimestamp: Int) -> Int {
        return initialTimestamp + time.numberOfMilliseconds
    }
    
    /**
     Uploads an image to Firebase and returns its image URL if it was uploaded successfully.
     
     - parameter image: Image to upload.
     - parameter completion: Completion block to pass the new image's URL to.
     */
    func uploadImage(image: UIImage, completion: @escaping (URL?) -> Void) {
        // Convert image to JPEG. Any file type supported by UIImage will work.
        let imageData = UIImageJPEGRepresentation(image, 0.8)!
        let uuid = UUID().uuidString
        let imageRef = storageRef.child("groupHeaderImages/\(uuid).jpg")
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.put(imageData, metadata: metadata) { (metadata, error) in
            if error != nil {
                // Uh-oh, an error occurred!
                // TODO: deal with this in some way
            } else {
                completion(metadata!.downloadURL())
            }
        }
    }
    
    /**
     Writes the listing to the database.
     
     - parameter listing: Dictionary with listing information.
     - parameter completion: Completion block to pass the new listing reference to.
     */
    func writeListing(_ listing: [String: Any], completion: @escaping (FIRDatabaseReference) -> Void) {
        let listingRef = ref.child("groups").childByAutoId()
        
        // Write the listing to the database. Firebase sets the createdTimestamp for use below.
        listingRef.setValue(listing) { (error, newListingRef) in
            if error != nil {
                // TODO: deal with this in some way
            }
            completion(newListingRef)
        }
    }
    
    func addGroupToUsersGroup(groupId: String, userId: String) {
        ref.child("users/\(userId)/groups/\(groupId)").setValue(true)
    }
}

// MARK: - UITextFieldDelegate protocol
//extension PostPriceViewController: UITextFieldDelegate {

// MARK: - UITextFieldDelegate protocol
//extension PostPriceViewController: UITextFieldDelegate {
//    
//    // Optional. Asks the delegate if the text field should process the pressing of the return button.
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if let nextTextField = textField.superview?.superview?.viewWithTag(textField.tag + 1) as? UITextField {
//            nextTextField.becomeFirstResponder()
//        } else {
//            dismissKeyboard()
//        }
//        
//        return false
//    }
//    
//    // Optional. Tells the delegate that editing stopped for the specified text field.
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        UIView.animate(
//            withDuration: 0.3,
//            delay: 0.0,
//            options: .curveEaseInOut,
//            animations: {
//                self.stackViewHeight.constant = 12.0
//        },
//            completion: nil
//        )
//    }
//}
