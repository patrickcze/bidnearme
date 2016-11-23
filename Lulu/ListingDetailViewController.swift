//
//  ListingDetailViewController.swift
//  Lulu
//
//  Created by Scott Campbell on 11/21/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import Alamofire
import AlamofireImage

class ListingDetailViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var listingImageView: UIImageView!
    @IBOutlet weak var listingTitleLabel: UILabel!
    @IBOutlet weak var listingDescriptionLabel: UILabel!
    @IBOutlet weak var listingCurrentPrice: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileRating: RatingControl!
    
    @IBOutlet weak var bidValueTextField: UITextField!
    @IBOutlet weak var placeBidButton: UIButton!
    
    // MARK: - Properties
    var listing: Listing?
    var ref: FIRDatabaseReference?
    
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get a reference to the firebase db and storage
        ref = FIRDatabase.database().reference()
        
        bidValueTextField.delegate = self
    
        // Setup the toolbar for the bidding textview
        let numberToolbar = UIToolbar()
        numberToolbar.barStyle = UIBarStyle.default
        
        numberToolbar.setItems([
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ListingDetailViewController.cancelPressed)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ListingDetailViewController.donePressed))
            ], animated: false)
        
        numberToolbar.isUserInteractionEnabled = true
        numberToolbar.sizeToFit()
        
        bidValueTextField.inputAccessoryView = numberToolbar
        
        // Setting user image to a circle
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        placeBidButton.layer.cornerRadius = 5.0
        
        // Checks if listing data is avaliable
        if let listing = listing {
            listingImageView.af_setImage(withURL: listing.photos[0])
            listingTitleLabel.text = listing.title
            listingDescriptionLabel.text = listing.description
            
            profileImageView.image = listing.seller.profileImage
            profileNameLabel.text = "\(listing.seller.firstName!) \(listing.seller.lastName!)"
            
            // Keeps the price on the image current with the highest bid
            ref?.child("listings").child(listing.listingID).observe(.value, with: { snapshot in
                let highestBidListingID = snapshot.childSnapshot(forPath: "winningBidId").value as! String
                var highestBidAmount = snapshot.childSnapshot(forPath: "startingPrice").value as! Double
                
                if !highestBidListingID.isEmpty {
                    highestBidAmount = snapshot.childSnapshot(forPath: "bids/\(highestBidListingID)/amount").value as! Double
                }
                

                self.listingCurrentPrice.text = "$" + String(highestBidAmount)
            })
            
            // TODO: Implement ratings for sellers.
            profileRating.rating = 3
            
            for button in profileRating.ratingButtons{
                button.isUserInteractionEnabled = false
            }
        }
    }
    
    func donePressed(){
        view.endEditing(true)
    }
    
    func cancelPressed(){
        view.endEditing(true) // or do something
    }
    
    // MARK: - Actions
    @IBAction func placeBidPress(_ sender: Any) {
        //Check if user is logged in
        if let user = FIRAuth.auth()?.currentUser {
            // Check if the user placed a bid value in the text field
            if let bidAmount = Double(bidValueTextField.text!) {

                let listingID = listing?.listingID
                let listingRef = ref?.child("listings").child(listingID!)
                
                //Check if bid table exists
                listingRef?.observeSingleEvent(of: .value, with: {snapshot in
                    if snapshot.hasChild("bids"){
                        //Checks that the desired bid is the highest
                        if self.isHighestBid(bidAmount: bidAmount, listingSnapshot: snapshot) {
                            let bidObject: [String : Any] = [
                                "amount": bidAmount,
                                "bidderId": user.uid,
                                "createdTimestamp" : FIRServerValue.timestamp()
                            ]
                            
                            self.placeBidInDB(bidObject: bidObject, listingRef: listingRef!)
                        }
                    }
                })
            }
        } else {
            // No user is signed in. Remind them with an alert
            alertUserNotLoggedIn()
        }
        
        bidValueTextField.text = ""
    }
    
    //Check if the users bid will be the new highest bid
    func isHighestBid(bidAmount: Double, listingSnapshot: FIRDataSnapshot) -> Bool {
        //Check to see if there is a current highest bid
        let highestBidId = listingSnapshot.childSnapshot(forPath: "winningBidId").value as! String
        
        if highestBidId.isEmpty{
            return true
        }
        
        let highestBidAmount = listingSnapshot.childSnapshot(forPath: "bids").childSnapshot(forPath: highestBidId).childSnapshot(forPath: "amount").value as! Double
        
        return bidAmount > highestBidAmount
    }

    // Executes the users bid and places it in the DB
    func placeBidInDB(bidObject:[String:Any], listingRef: FIRDatabaseReference) {
        let bidRef = listingRef.child("bids").childByAutoId()
        
        bidRef.setValue(bidObject) { (error, bidRef) in
            if error == nil {
                self.updateListingWinningBidId(listingRef: listingRef, highestBidId: bidRef.key)
            }
        }
    }

    // Updates the winning bid field in the listing
    func updateListingWinningBidId(listingRef: FIRDatabaseReference, highestBidId: String) {
        listingRef.child("winningBidId").setValue(highestBidId)
    }
    
    // Lets the user know that they need to login to bid
    func alertUserNotLoggedIn() {
        let alert = UIAlertController(title: "You're not signed in...", message: "Please sign into your account in the profile tab", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension ListingDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // TODO: deal with this in some way
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // TODO: deal with this in some way
    }
}
