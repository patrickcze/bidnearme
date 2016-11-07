//
//  HomeViewController.swift
//  Lulu
//
//  Created by Scott Campbell on 10/30/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import Alamofire
import AlamofireImage

class HomeViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var listingsCollectionView: UICollectionView!
    
    // MARK: - Properties
    let reuseIdentifier = "ListingCollectionCell"
    var ref: FIRDatabaseReference!
    var storage: FIRStorage!
    let newListing:Listing! = nil
    var image:UIImage! = nil
    
    // dummy listings to test UI, just temporary :)
    var tempData: [Listing] = []
    
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get a reference to the firebase db and storage
        ref = FIRDatabase.database().reference()
        
        //Get a snapshot of listings
        let listingRef = self.ref.child("listings")
        
        //Watch for changes to listings
        listingRef.observe(FIRDataEventType.value){(snap: FIRDataSnapshot) in
            let enumerator = snap.children
            var tempListing: Listing
            
            //Iterate over listings
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                //Get basic info about the listing
                let title = rest.childSnapshot(forPath: "title").value as? String
                let currentPrice = rest.childSnapshot(forPath: "currentPrice").value as? Int
                let desc = rest.childSnapshot(forPath: "desc").value as? String
                let imageURLS = rest.childSnapshot(forPath: "imageURL")
                
                var imageURLArray:[URL] = []
                var index = 0
                
                for item in 0...imageURLS.childrenCount-1 {
                    let varNum = String(item)
                    let urlString = imageURLS.childSnapshot(forPath: varNum).value as! String
                    
                    print("url")
                    print(URL(string:urlString))
                    
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
                tempListing = Listing(rest.key, imageURLArray, title!, desc!, currentPrice!, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!,"Scott","Campbell"))
                
                self.tempData.append(tempListing)
            }
            
            
            //Copying some listings for the profile page - TEMPORAL - RONNY
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            if appDelegate != nil
            {
                appDelegate?.dummyUser.soldListings = []
                appDelegate?.dummyUser.buyingListings = [self.tempData[0]]
                appDelegate?.dummyUser.favoritedListings = [self.tempData[1]]
                appDelegate?.dummyUser.soldListings = [self.tempData[2]]
                appDelegate?.dummyUser.postedListings = [self.tempData[3]]
            }
            
            
            //Refresh listing view
            self.listingsCollectionView.reloadData()
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
}

// MARK: - UICollectionViewDataSource protocol
extension HomeViewController: UICollectionViewDataSource {
    
    // Required. Tell view how many cells to make.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tempData.count
    }
    
    // Required. Make a cell for each row in index path.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeCollectionViewCell
        cell.listing = tempData[indexPath.row]
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate protocol
extension HomeViewController: UICollectionViewDelegate {}
