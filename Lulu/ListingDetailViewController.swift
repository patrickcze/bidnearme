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
            
            ref?.child("listings").child(listing.listingID).child("bids").observe(.value, with: { snapshot in
                let enumerator = snapshot.children
                var maxPrice = listing.startPrice!
                
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    let bidAmount = rest.childSnapshot(forPath: "amount").value as! Double
                    
                    if (bidAmount > maxPrice) {
                        maxPrice = bidAmount
                    }
                }
                
                self.listingCurrentPrice.text = "$" + String(maxPrice)
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
                //TODO: Validate input of price
                
                let listingID = listing?.listingID
                let listingRef = ref?.child("listings").child(listingID!)
                
                //Check if bid table exists
                listingRef?.observeSingleEvent(of: .value, with: {snapshot in
                    if snapshot.hasChild("bids"){
                        
                        //Create new location for bid
                        let bidsRef = listingRef?.child("bids").childByAutoId()
                        
                        let bidObject: [String: Any] = [
                            "bidderID": user.uid,
                            "amount": bidAmount,
                            "createdTimestamp": FIRServerValue.timestamp()
                        ]
                        
                        bidsRef?.setValue(bidObject) { (error) in
                            if error != nil {
                                // TODO: deal with this in some way
                            }
                        }
                    }
                    else {
                        // TODO: bids table is missing should never happen
                    }
                })
            }
        } else {
            // No user is signed in. Remind them with an alert
            let alert = UIAlertController(title: "Your not signed in...", message: "Please sign into your account in the profile tab", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        bidValueTextField.text = ""
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
