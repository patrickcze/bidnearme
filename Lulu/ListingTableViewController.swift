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
    
    // MARK: - Outlets
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    // MARK: - Properties
    let cellIdentifier = "ProfileCell"
    var listingsRef: FIRDatabaseReference!
    var listingIds: [String]!
    var listings: [Listing?]!
    var listingType : ListingType!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationTitle.title = listingType.description
        retrieveListings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register custom TableViewCell nib.
        let nib = UINib(nibName: "ProfileTableViewCell", bundle: nil)
        self.tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.tableView.register(nib,forCellReuseIdentifier: cellIdentifier)
    }
    
    // TO-DO: ask about buyout price in listing and FINISH implementing this function
    /**
     Gets listing information
     */
    func getListing(withId listingId: String, completion: @escaping (Listing?) -> Void) {
        
        listingsRef = FIRDatabase.database().reference().child("listings")
        listingsRef.child(listingId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let listing = snapshot.value as? [String: Any]  else {
                completion(nil)
                return
            }
            
            //let auctionEndTimestamp = listing["auctionEndTimestamp"] as! Int
            //let createdTimestamp = listing["createdTimestamp"] as? Int ?? -1
            let description = listing["description"] as? String ?? ""
            let imageUrls = listing["imageUrls"] as? [String] ?? ["URL for no photo available? from DB?"]
            let imageURLS = imageUrls.map{URL.init(string: $0)} as! [URL]
            //let sellerId = listing?["sellerId"] as! String
            let startingPrice = listing["startingPrice"] as? Double ?? 0.00
            let buyoutPrice = 99999// <- ASK ABOUT THIS FIELD IN DB
            let title = listing["title"] as? String ?? "N/A"
            let winningBidId = listing["winningBidId"] as! String
            let tempListing = Listing("ID", imageURLS, title, description, startingPrice, buyoutPrice, "Oct 30", "Nov 9", User())
            
            if let bids = listing["bids"] as? [String:Any] {
                if let highestBid = bids[winningBidId] as? [String : Any] {
                    let amount = highestBid["amount"] as! Double
                    let bidderId = highestBid["bidderId"] as! String
                    let createdTimestamp = highestBid["createdTimestamp"] as! Int
                    tempListing.winningBid = Bid(amount,bidderId,createdTimestamp)
                }
            }
            completion(tempListing)
            // ASK ABOUT IF we need to initialize a new user with the given ID or just pass the userID. ListingViewDetails should retrieve the user from the DB
        })
    }
    
    // TO-DO: Is it efficient to call self.tableView.reloadData() inside the
    // closure below?
    // The table updates because of that. If I call reloadData() (in viewWillAppear() after invoking retrieveListings())
    // the tableView does not update.
    func retrieveListings() {
        listings = []
        for listingId in listingIds {
            getListing(withId: listingId){ (listing)  in
                self.listings.append(listing)
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProfileTableViewCell
        let index = indexPath as NSIndexPath
        if let listing = listings[index.row] {
            setupCell(cell, listing)
        } else {
            cell = ProfileTableViewCell()
        }
        
        return cell
    }
    
    // TO-DO: finish implementing this function. Ask what should I display for each different listing type
    func setupCell(_ cell: ProfileTableViewCell, _ listing: Listing) {
        
        cell.itemTitle.text = listing.title
        if let photoUrl = listing.photos.first {
            cell.itemPhoto.af_setImage(withURL: photoUrl)
        } else {
            cell.itemPhoto.image = UIImage()  // display a "photo no available"?
        }
        
        var bidAmount = listing.startPrice.description
        
        if let b = listing.winningBid {
            bidAmount = b.amount.description
        }
        
        switch (listingType.description) {
            
        case "bidding", "watching", "selling": // buyout and highest bid
            cell.bigLabel.text = "Buy now!" //listing.buyoutPrice.description
            cell.smallLabel.text = bidAmount
        case "won", "sold": //  highest bid amount and date
            cell.bigLabel.text = bidAmount
            cell.smallLabel.text = listing.endDate
        case "lost": // date and bid that won but with different color?
            cell.bigLabel.text = bidAmount
            cell.bigLabel.backgroundColor = UIColor.red
            cell.bigLabel.alpha = 0.7
            cell.bigLabel.text = bidAmount
            cell.smallLabel.text = listing.endDate
        default:
            fatalError("*** Switch statement was not exhaustive enough: ListingTableViewController->setUpCell")
        }
    }
}
