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
import FirebaseAuth
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
    var listings: [Listing] = []
    var filteredData = [Listing]()
    
    var refreshControl: UIRefreshControl!
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        //Prevents the search bar and cancel button from disappearing when searching
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        
        return searchController
    }()
    
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This section sets the bid near me logo in the top left corner
        let logoImage = UIImage.init(named: "appLogo")
        let logoImageView = UIImageView.init(image: logoImage)
        logoImageView.frame = CGRect(x: -40, y: 5, width: 125, height: 25)
        logoImageView.contentMode = .scaleAspectFit
        let imageItem = UIBarButtonItem.init(customView: logoImageView)
        let negativeSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15
        navigationItem.leftBarButtonItems = [negativeSpacer, imageItem]
        
        // Configure searchbar with autolayout & add it to view.
        searchController.searchBar.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        searchController.searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //Adds a refresh controller to the listing collection be able to refresh with a pull down
        listingsCollectionView.alwaysBounceVertical = true
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(sender:)), for: .valueChanged)
        self.listingsCollectionView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Get a reference to the firebase db and storage
        ref = FIRDatabase.database().reference()
        
        //Prevents listing list reloading every time you come into the view
        if listings.isEmpty {
            loadCurrentListingsFromFirebase()
        }
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
    
    //Implements actions required after the pull to refresh has been triggered
    func handleRefresh(sender:AnyObject) {
        loadCurrentListingsFromFirebase()
        self.refreshControl?.endRefreshing()
    }
    
    //Loads the current valid listings from the firebase database
    func loadCurrentListingsFromFirebase (){
        let currentEpochTime = NSDate().timeIntervalSince1970 as Double * 1000
        
        //Get a snapshot of listings
        let listingRef = ref.child("listings").queryOrdered(byChild: "auctionEndTimestamp").queryStarting(atValue: currentEpochTime)
        
        //Get list of current listings
        listingRef.observeSingleEvent(of: .value, with: { (snap) in
            let enumerator = snap.children
            
            //Iterate over listings
            while let listingSnapshot = enumerator.nextObject() as? FIRDataSnapshot {
                // Get basic info about the listing
                let title = listingSnapshot.childSnapshot(forPath: "title").value as? String
                let desc = listingSnapshot.childSnapshot(forPath: "description").value as? String
                let imageURLS = listingSnapshot.childSnapshot(forPath: "imageUrls")
                
                var imageURLArray:[URL] = []
                var index = 0
                
                // Get a list of URLs of the listing images
                for item in 0...imageURLS.childrenCount-1 {
                    let varNum = String(item)
                    let urlString = imageURLS.childSnapshot(forPath: varNum).value as! String
                    
                    imageURLArray.append(URL(string:urlString)!)
                }
                
                // Check for existing listings
                for listing in self.listings {
                    if listing.listingID == listingSnapshot.key {
                        self.listings.remove(at: index)
                    }
                    index+=1
                }
                
                // Handle getting the listings highest price
                let highestBidId = listingSnapshot.childSnapshot(forPath: "winningBidId").value as! String
                var highestBidAmount = listingSnapshot.childSnapshot(forPath: "startingPrice").value as! Double
                
                if !highestBidId.isEmpty {
                    highestBidAmount = listingSnapshot.childSnapshot(forPath: "bids").childSnapshot(forPath: highestBidId).childSnapshot(forPath: "amount").value as! Double
                }
                
                // Check to see if the seller Id is present before grabbing the details of the seller
                if let sellerId = listingSnapshot.childSnapshot(forPath: "sellerId").value as? String {
                    // Get the details for the seller
                    self.ref.child("users").child(sellerId).observeSingleEvent(of: .value, with: { (sellerDataSnap) in
                        
                        // Gather imporetant details abouyt the seller
                        let sellerName = sellerDataSnap.childSnapshot(forPath: "name").value as? String
                        let sellerCreatedTimestamp = sellerDataSnap.childSnapshot(forPath: "createdTimestamp").value as? Int
                        let sellerImageUrl = sellerDataSnap.childSnapshot(forPath: "profileImageUrl").value as? String
                        
                        let seller = User(uid: sellerId, name: sellerName!, profileImageUrl: URL(string: sellerImageUrl!), createdTimestamp: sellerCreatedTimestamp!)
                        
                        // Create a listing for the data within the snapshot
                        let listing = Listing(listingSnapshot.key, imageURLArray, title!, desc!, highestBidAmount, 25, "Oct 30", "Nov 9", seller)
                        
                        self.listings.append(listing)
                        
                        //Refresh listing view
                        self.listingsCollectionView.reloadData()
                    })
                }
            }
        })
    }
    
    // MARK: - Navigation
    
    // Notifies the view controller that a segue is about to be performed.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowListingDetail" {
            if let indexPath = listingsCollectionView.indexPathsForSelectedItems {
                let destinationController = segue.destination as! ListingDetailViewController
                destinationController.listing = listings[indexPath[0].row]
            }
        }
    }
}

// MARK: - UICollectionViewDataSource protocol
extension HomeViewController: UICollectionViewDataSource {
    
    // Required: Tell view how many cells to make.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchController.isActive ? filteredData.count : listings.count
    }
    
    // Required: Make a cell for each row in index path.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = HomeCollectionViewCell()
        
        // Filter cells based on search.
        if let filteredCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? HomeCollectionViewCell {
            filteredCell.listing = searchController.isActive ? filteredData[indexPath.row] : listings[indexPath.row]
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
        filteredData = listings.filter({ (listing) -> Bool in
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

// MARK: - UITextFieldDelegate
extension CameraViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Hide the keyboard
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // TODO: deal with this in some way
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // TODO: deal with this in some way
    }
}
