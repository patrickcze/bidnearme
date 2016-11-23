//
//  ListingTableViewController.swift
//  Lulu
//
//  Created by Ronny on 2016-11-09.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ListingTableViewController: UITableViewController {
    
    // MARK: - Properties
    let cellIdentifier = "ProfileCell"
    var listingsRef: FIRDatabaseReference!
    var listingIds: [String]!
    var listings: [Listing]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listingsRef = FIRDatabase.database().reference().child("listings")
        retrieveListings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register custom TableViewCell nib.
        let nib = UINib(nibName: "ProfileTableViewCell", bundle: nil)
        self.tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.tableView.register(nib,forCellReuseIdentifier: cellIdentifier)
    }
    
    func retrieveListings() {
        listings = []
        // TODO:
        /*
        for listingId in listingIds {

            listingsRef.child(listingId).observeSingleEvent(of: .value, with: { (snapshot)
                let listing = snapshot.value as? [String: Any]
                self.listings.append()
            })
        }
        */
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProfileTableViewCell
        let index = indexPath as NSIndexPath
        let listing = listings[index.row]
        cell.itemTitle.text = listing.title
        cell.itemPhoto.image = UIImage()
        return cell
    }
}
