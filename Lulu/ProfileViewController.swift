//
//  ProfileViewController.swift
//  Lulu
//
//  Created by Ronny on 2016-10-30.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet weak var upperView: UIView! // the background for the top part of the profile page (Name, profile pciture, rating label, etc.
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var specialLabel: UILabel!
    @IBOutlet weak var listingTypeTableView: UITableView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertLabel: UILabel!
    
    // MARK: - Properties
    var ref: FIRDatabaseReference!
    
    var profileUser: User?
    
    let listingTypes = [
        ListingType.selling,
        ListingType.sold,
        ListingType.bidding,
        ListingType.watching,
        ListingType.won,
        ListingType.lost
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref = FIRDatabase.database().reference()
        
        loginButton.title = "Log out"
        alertLabel.isHidden = true
        alertView.isHidden = true
        
        guard let userId = FIRAuth.auth()?.currentUser?.uid else {
            alertLabel.text = " Please log-in!"
            loginButton.title = "Log in"
            profileNameLabel.text = ""
            ratingLabel.text = ""
            memberLabel.text = ""
            specialLabel.text = ""
            alertView.isHidden = false
            alertLabel.isHidden = false
            profilePicture.image = UIImage(named: "nophoto")
            return
        }
        
        getUser(withId: userId) { (user) in
            self.profileUser = user
            self.populateUserViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize database reference.
        
        // Do any additional setup after loading the view.
        listingTypeTableView.delegate = self
        listingTypeTableView.dataSource = self
        
        // Making the imageView Circular
        if let profilePicture = profilePicture {
            profilePicture.layoutIfNeeded()
            profilePicture.layer.masksToBounds = false
            profilePicture.layer.cornerRadius = profilePicture.frame.height/2
            profilePicture.clipsToBounds = true
            profilePicture.contentMode = UIViewContentMode.scaleToFill
        }
        
        // Making upper view and bottom table view frame corners rounded
        upperView.layer.cornerRadius = 3
        upperView.layer.masksToBounds = true
        listingTypeTableView.layer.cornerRadius = 3
        listingTypeTableView.layer.masksToBounds = true
        alertLabel.layer.cornerRadius = 5
        alertLabel.layer.masksToBounds = true
    }
    
    
    // TO-DO: finish updating the top part of profile view by using the user's information
    /**
     Populates the user views with info if the profileUser has been specified.
     */
    func populateUserViews() {
        guard let user = profileUser else {
            fatalError("This should not be called until profileUser is initialized.")
        }
        
        if let profileImageUrl = user.profileImageUrl {
            profilePicture.af_setImage(withURL: profileImageUrl)
        }
        
        if let name = user.name {
            profileNameLabel.text = name
        }
        
        // TO-DO ->
        ratingLabel.text = "4.6 stars"
        memberLabel.text = "Member since: 2016"
        specialLabel.text = "Replies quickly"
    }
    
    /**
     Gets user information as a User and calls completion with the User object.
     */
    func getUser(withId id: String, completion: @escaping (User?) -> Void) {
        ref.child("users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            let name = user["name"] as! String
            let createdTimestamp = user["createdTimestamp"] as! Int
            
            var profileImageUrl: URL?
            if let profileImageUrlString = user["profileImageUrl"] as? String, !profileImageUrlString.isEmpty {
                profileImageUrl = URL(string: profileImageUrlString)
            }
            
            // Retrieve user listings.
            var listingIdsByType = [ListingType: [String]]()
            
            // Listings: ["selling" -> ["listingId1" -> true, "listingId2" -> true], "buying" -> []]
            if let listingTreeIds = user["listings"] as? [String: [String: Bool]] {
                listingIdsByType = self.getListingIdsByType(listingTreeIds: listingTreeIds)
            }

            completion(User(UId: id, name: name, profileImageUrl: profileImageUrl, createdTimestamp: createdTimestamp, listingIdsByType: listingIdsByType, ratings: [:], groups: []))

        })
    }
    
    /**
     Get all listing IDs of every listing type. listingType.description must exactly match one of the database listing types under User.
     */
    func getListingIdsByType(listingTreeIds: [String: [String: Bool]]) -> [ListingType: [String]] {
        var listingIdsByType = [ListingType: [String]]()
        
        // For every case in ListingType, e.g. selling, buying, etc., retrieve just the listing IDs; ignoring the booleans.
        for listingType in ListingType.allValues {
            listingIdsByType[listingType] = []
            
            if let listingIdsOfType = listingTreeIds[listingType.description], !listingIdsOfType.isEmpty {
                listingIdsByType[listingType] = Array(listingIdsOfType.keys) // Gets listing IDs as an array.
            }
        }
        return listingIdsByType
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Set up listingTypeTableView before seguing. Give it proper listings, selling, buying, or etc., to display based on row selected.
        if segue.identifier != nil && segue.identifier == "ListingTableViewSegue" {
            let listingTableViewController = segue.destination as! ListingTableViewController
            
            guard let row = listingTypeTableView.indexPathForSelectedRow?.row else {
                fatalError("Row does not exist in table view.")
            }
            
            let listingType = listingTypes[row]
            listingTableViewController.listingIds = profileUser?.listingIdsByType[listingType]
            listingTableViewController.listingType = listingType
            listingTableViewController.uid = profileUser?.UId
        }
    }
}

// MARK: - UITableViewDataSource protocol
extension ProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listingTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListingTypeCell", for: indexPath) as! ListingTypeTableViewCell
        let index = indexPath as NSIndexPath
        let capitalizedListingTypeName = listingTypes[index.row].description.capitalized
        cell.name.text = capitalizedListingTypeName
        return cell
    }
    
    // making all the rows to fit inside the tableView frame
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height/CGFloat(listingTypes.count)
    }
    
    @objc(tableView:estimatedHeightForRowAtIndexPath:) func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height/CGFloat(listingTypes.count)
    }
}

// MARK: - UITableViewDelegate protocol
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.listingTypeTableView.deselectRow(at: indexPath, animated: true)
    }
}
