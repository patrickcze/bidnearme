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
import M13Checkbox

class NewGroupMembersViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var memberTableView: UITableView!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var newGroupButton: UIButton!
    
    // MARK: - Properties
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var listingPhoto: UIImage!
    var listingTitle: String!
    var listingDescription: String!
    var auctionDurationPicker = UIPickerView()
    
    var users = [User]()
    
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
        
        // Do any additional setup after loading the view.
        memberTableView.delegate = self
        memberTableView.dataSource = self
        
        //Get list of current listings
        ref.child("users").observeSingleEvent(of: .value, with: { (snap) in
            let enumerator = snap.children
            
            //Iterate over listings
            while let userSnapshot = enumerator.nextObject() as? FIRDataSnapshot {
                // Get basic info about the listing
                guard let userData = userSnapshot.value as? [String: Any]  else {
                    //TO-DO: Handle error
                    return
                }
                
                guard
                    let name = userData["name"] as? String,
                    let createdTimestamp = userData["createdTimestamp"] as? Int else {
                        //TO-DO: Handle error
                        return
                }
                
                let user = User(uid: userSnapshot.key, name: name, profileImageUrl: URL(string: ""), createdTimestamp: createdTimestamp)
                if user.uid != FIRAuth.auth()?.currentUser?.uid{
                    self.users.append(user)
                    self.memberTableView.reloadData()
                }
            }
        })
    
    }
    
    // MARK: - Observers
    
    // Observe NSNotification.Name.UIKeyboardWillShow
    func keyboardWillAppear(notification: NSNotification) {
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
        
        // Create the alert to distract user as the group is created
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
        displayCompletionAlert(alert: alert)
        
        //Determine which users are part of that group
        var memberIds = [currentUserId]
        
        for cell in memberTableView.visibleCells {
            if let cellThing = cell as? GroupMemberTableViewCell {
                if cellThing.memberStateCheckBox.checkState == .checked {
                    memberIds.append(cellThing.user.uid)
                }
            }
        }
        
        // Upload the image and write the listing if the image was successfully uploaded.
        uploadImage(image: image) { (imageUrl) in
            guard let imageUrlString = imageUrl?.absoluteString else {
                return
            }
            
            var idsDic: [String: Bool] = [:]
            
            for id in memberIds {
                idsDic[id] = true
            }
            
            let group: [String: Any] = [
                "name": title,
                "description": description,
                "imageUrl": imageUrlString,
                "createdTimestamp": FIRServerValue.timestamp(), // Firebase replaces this with its timestamp.
                "members": idsDic,
                "listings": []
            ]
            
            // TODO: Allow user input for auction duration.
            self.writeListing(group) { (listingRef) in
                for id in memberIds {
                    self.addGroupToUsersGroup(groupId: listingRef.key, userId: id)
                }
                
                self.performSegue(withIdentifier: "UnwindToRoot", sender: self)
                alert.dismiss(animated: true, completion: nil)
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
    
    // Display a alert to pause the user while we create the group
    func displayCompletionAlert(alert: UIAlertController){
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.30)
        let width:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.width * 0.80)
        
        alert.view.addConstraint(height)
        alert.view.addConstraint(width)
        
        let checkbox = M13Checkbox(frame: CGRect(x: (width.constant-80.0)/2, y: (height.constant-80.0)/2, width: 80.0, height: 80.0))
        checkbox.stateChangeAnimation = .stroke
        checkbox.animationDuration = 0.75
        
        alert.view.addSubview(checkbox)
        
        // show the alert
        self.present(alert, animated: true, completion: {
            checkbox.toggleCheckState(true)
        })
    }
}

// MARK: - UITableViewDataSource protocol
extension NewGroupMembersViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberTableViewCell", for: indexPath) as! GroupMemberTableViewCell
        
        cell.memberName.text = self.users[indexPath.row].name
        cell.user = self.users[indexPath.row]
        
        cell.memberStateCheckBox.tintColor = ColorPalette.bidBlue
        cell.memberStateCheckBox.stateChangeAnimation = .expand(.fill)
        
        return cell
    }
}

// MARK: - UITableViewDelegate protocol
extension NewGroupMembersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.memberTableView.deselectRow(at: indexPath, animated: true)
    }
}

