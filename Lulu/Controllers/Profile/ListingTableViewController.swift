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
    var listings: [Listing?]!
    var listingType : ListingType!
    var uid : String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // listingType and uid should be set before this view. Currently, it is being called in ProfileViewController before seguing here
        guard let _ = listingType, let _ = uid else{
            fatalError("listingType = nil or uid = nil -> ListingTableViewController->viewWillAppear()")
        }
        
        navigationTitle.title = listingType.description.capitalized
        retrieveListings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register custom TableViewCell nib.
        let nib = UINib(nibName: "ProfileTableViewCell", bundle: nil)
        self.tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.tableView.register(nib,forCellReuseIdentifier: cellIdentifier)
    }
    
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
            
            let buyoutPrice = 99999.00// No supported yet
            
            guard
                let createdTimestamp = listing["createdTimestamp"] as? Int,
                let auctionEndTimestamp = listing["auctionEndTimestamp"] as? Int,
                let startingPrice = listing["startingPrice"] as? Double,
                let description = listing["description"] as? String,
                let winningBidId = listing["winningBidId"] as? String,
                let title = listing["title"] as? String else {
                    //TO-DO: Handle error
                    return
            }
            
            var imageUrls : [URL] = []
            if let imageUrlStrings = listing["imageUrls"] as? [String] {
                imageUrls = imageUrlStrings.map{URL.init(string: $0)} as! [URL]
            }
            let aListing = Listing(listingId: listingId, sellerId: listing["sellerId"] as! String, imageUrls: imageUrls, title: title, description: description, startPrice: startingPrice, buyoutPrice: buyoutPrice, currencyCode: CurrencyCode.cad, createdTimestamp: createdTimestamp, auctionEndTimestamp: auctionEndTimestamp, winningBidId: winningBidId, bids: [:])
            
            completion(aListing)
        })
    }
    
    func retrieveListings() {
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).child("listings").child(listingType.description).observeSingleEvent(of: .value, with: { (snapshot) in
            guard var aListingType = snapshot.value as? [String:Bool] else {
                // user does not have this type of listing
                return
            }
            self.listings = []
            for (listingId,_) in aListingType {
                self.getListing(withId: listingId){ (listing)  in
                    
                    // this avoids appeding a null listing that does not exist in the DB
                    if (listing != nil) {
                        self.listings.append(listing)
                    } else {
                        aListingType[listingId] = nil
                    }
                    if (self.listings.count == aListingType.count) {
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listings == nil {
            return 0
        }
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ListingDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func setupCell(_ cell: ProfileTableViewCell, _ listing: Listing) {
        cell.itemTitle.text = listing.title
        cell.itemPhoto.af_setImage(withURL: listing.imageUrls[0])
        cell.bigLabel.textColor = UIColor.black // for selling (if there is not bidders) and watching
        
        // Check if there is a winning bid
        if listing.winningBidId.isEmpty {
            cell.bigLabel.text = String(format: "$%.2f", listing.startPrice!)
        } else {
            // Get the data for the current winning bid
            getListingBidById(listingId: (listing.listingId)!, bidId: listing.winningBidId, completion: { (bid) in
                // Set the price label
                cell.bigLabel.text = String(format: "$%.2f", (bid?.amount)!)
                
                switch (self.listingType!) {
                case .bidding: // text color is green if user bid is winning. Otherwise, red
                    if bid?.bidderId == self.uid! {
                        cell.bigLabel.textColor = UIColor(colorLiteralRed: 0.13, green: 0.55, blue: 0.13, alpha: 1)
                    } else {
                        cell.bigLabel.textColor = UIColor.red
                    }
                case .watching: // text color black
                    break
                case .selling,.won, .sold : // there is at least a bidder, so text color is green
                    cell.bigLabel.textColor = UIColor(colorLiteralRed: 0.13, green: 0.55, blue: 0.13, alpha: 1)
                case .lost: // text color always red
                    cell.bigLabel.textColor = UIColor.red
                }
            })
        }
        
        // Set the dates and time to show when the auction will end
        let endDate = Date(timeIntervalSince1970: TimeInterval(listing.auctionEndTimestamp/1000))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:m a"
        
        cell.smallLabel.text = dateFormatter.string(from: endDate)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            if (segue.identifier == "ListingDetail") {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let destinationController = segue.destination as! ListingDetailViewController
                    destinationController.listing = listings[indexPath.row]
                }
            }
    }
}
