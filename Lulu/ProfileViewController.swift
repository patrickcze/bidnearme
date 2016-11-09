//
//  ProfileViewController.swift
//  Lulu
//
//  Created by Ronny on 2016-10-30.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var specialLabel: UILabel!
    @IBOutlet weak var listingTypeTableView: UITableView!
    @IBOutlet weak var upperView: UIView! // the background for the top part of the profile page (Name, profile pciture, rating label, etc.
    
    // MARK: - Properties
    let listingTypes = ["Buying", "Bought", "Selling", "Sold", "Favorites"]
    var allListings : [[Listing]]!
    
    // Temporary
    var tempUser : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.listingTypeTableView.delegate = self
        self.listingTypeTableView.dataSource = self
        
        // Making the imageView Circular
        profilePicture?.layoutIfNeeded()
        profilePicture?.layer.masksToBounds = false
        profilePicture?.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture?.clipsToBounds = true
        profilePicture.contentMode = UIViewContentMode.scaleToFill
        
        // Making upperview and bottom table view frame corners rounded
        upperView.layer.cornerRadius = 3
        listingTypeTableView.layer.cornerRadius = 3
        
        // accessing data stored in the appDelegate
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let temp = appDelegate?.dummyUser {
            tempUser = temp
            profilePicture.image = tempUser.profileImage
            
            allListings = [
                tempUser.buyingListings,   // 0
                tempUser.buyingListings,   // 1 <- THIS should be boughtListings
                tempUser.postedListings,   // 2
                tempUser.soldListings,     // 3
                tempUser.favoritedListings // 4
            ]
        }
        else { // handle this more properly with exceptions later
            print("*** ProfileViewController: user NULL ***")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // setting up the type of listing that ListingTableViewController will be displaying
        if (segue.identifier != nil && segue.identifier == "ListingTableViewSegue"){
            let row = self.listingTypeTableView.indexPathForSelectedRow?.row
            let listingTableViewController = segue.destination as! ListingTableViewController
            listingTableViewController.listingType = row!
            listingTableViewController.listings = allListings[row!]
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
        cell.name.text = listingTypes[index.row]
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
extension ProfileViewController: UITableViewDelegate {}

