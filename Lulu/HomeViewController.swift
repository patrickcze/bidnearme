//
//  HomeViewController.swift
//  Lulu
//
//  Created by Scott Campbell on 10/30/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase
import Alamofire
import AlamofireImage

private let reuseIdentifier = "ListingCollectionCell"

class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var searchBarContainerView: UIView!
    @IBOutlet weak var listingsCollectionView: UICollectionView!
    
    // MARK: - Properties
    var ref: FIRDatabaseReference!
    var storage: FIRStorage!
    let newListing: Listing! = nil
    var image: UIImage! = nil
    var tempData: [Listing] = []
    var filteredData = [Listing]()
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        
        return searchController
    }()
    
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure searchbar with autolayout & add it to view.
        searchController.searchBar.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        searchBarContainerView.addSubview(searchController.searchBar)
        searchController.searchBar.sizeToFit()
        
        //Get a reference to the firebase db and storage
        ref = FIRDatabase.database().reference()
        
        //Get a snapshot of listings
        let listingRef = ref.child("listings")
        
        //Watch for changes to listings
        listingRef.observe(FIRDataEventType.value, with: { (snap) in
            let enumerator = snap.children
            var tempListing: Listing
            
            //Iterate over listings
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                //Get basic info about the listing
                let title = rest.childSnapshot(forPath: "title").value as? String
                let currentPrice = 25
                let desc = rest.childSnapshot(forPath: "description").value as? String
                let imageURLS = rest.childSnapshot(forPath: "imageUrls")
                
                var imageURLArray:[URL] = []
                var index = 0
                
                for item in 0...imageURLS.childrenCount-1 {
                    let varNum = String(item)
                    let urlString = imageURLS.childSnapshot(forPath: varNum).value as! String
                    
                    imageURLArray.append(URL(string:urlString)!)
                }
                
                //Check for existing listings
                for listing in self.tempData {
                    if listing.listingID == rest.key {
                        self.tempData.remove(at: index)
                    }
                    index+=1
                }

                // Create a listing for the data within the snapshot
                tempListing = Listing(rest.key, imageURLArray, title!, desc!, currentPrice, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!,"Scott","Campbell"))
                
                self.tempData.append(tempListing)
            }
        
            
            // ronny - Copying some listings for the profile page - TEMPORAL
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            if appDelegate != nil && self.tempData.count > 0
            {
                appDelegate?.dummyUser.buyingListings = [self.tempData[0]]
                appDelegate?.dummyUser.favoritedListings = [self.tempData[0]]
                appDelegate?.dummyUser.soldListings = [self.tempData[0]]
                appDelegate?.dummyUser.postedListings = [self.tempData[0]]
            }
            else {
                appDelegate?.dummyUser.buyingListings = []
                appDelegate?.dummyUser.favoritedListings = []
                appDelegate?.dummyUser.soldListings = []
                appDelegate?.dummyUser.postedListings = []
            }
            // -----------------------
            
            //Refresh listing view
            self.listingsCollectionView.reloadData()
        })
    }
    
    // Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Notifies view controller that it's view laid out subviews.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Adjust listingsCollectionViewCell width to screensize.
        if let layout = listingsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let cellWidth = (view.bounds.width - 36.0) / 2.0
            let cellHeight = layout.itemSize.height
            layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
            layout.invalidateLayout()
        }
    }
}

// MARK: - UICollectionViewDataSource protocol
extension HomeViewController: UICollectionViewDataSource {
    
    // Required: Tell view how many cells to make.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchController.isActive ? filteredData.count : tempData.count
    }
    
    // Required: Make a cell for each row in index path.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = HomeCollectionViewCell()
        
        // Filter cells based on search.
        if let filteredCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? HomeCollectionViewCell {
            filteredCell.listing = searchController.isActive ? filteredData[indexPath.row] : tempData[indexPath.row]
            cell = filteredCell
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate protocol
extension HomeViewController: UICollectionViewDelegate {}

// MARK: - UISearchResultsUpdating protocol
extension HomeViewController: UISearchResultsUpdating {
    
    // Required: Called when the search bar becomes the first responder or when the user makes changes inside the search bar.
    func updateSearchResults(for searchController: UISearchController) {
        filterData()
        listingsCollectionView.reloadData()
    }
    
    // Helper: Filter listing cells according to search term.
    func filterData() {
        filteredData = tempData.filter({ (listing) -> Bool in
            if let searchTerm = self.searchController.searchBar.text {
                let searchTermMatches = self.searchString(listing, searchTerm: searchTerm).count > 0
                
                if searchTermMatches { return true }
            }
            
            return false
        })
    }
    
    // Helper: Match listing titles against search term.
    func searchString(_ listing: Listing, searchTerm: String) -> Array<AnyObject> {
        var matches: Array<AnyObject> = []
        
        do {
            let regex = try NSRegularExpression(pattern: searchTerm, options: [.caseInsensitive, .allowCommentsAndWhitespace])
            let range = NSMakeRange(0, listing.title.characters.count)
            matches = regex.matches(in: listing.title, options: [], range: range)
        } catch _ {}
        
        return matches
    }
}
