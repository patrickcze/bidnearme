//
//  ListingDetailViewController.swift
//  Lulu
//
//  Created by Scott Campbell on 11/21/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import MapKit
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
    @IBOutlet weak var listingPriceTag: UIView!
    @IBOutlet weak var listingCurrentPrice: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileRating: RatingControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeBidButton: UIButton!
    
    // MARK: - Properties
    var listing: Listing?
    var textField: UITextField!
    var toolbarTextField: UITextField!
    var ref: FIRDatabaseReference?
    
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeBidButton.backgroundColor = ColorPalette.bidblue
        
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.keyboardType = .numberPad
        textField.delegate = self
        view.addSubview(textField)
        
        //Get a reference to the firebase db and storage
        ref = FIRDatabase.database().reference()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        placeBidButton.backgroundColor = ColorPalette.bidblue
        listingPriceTag.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        mapView.layer.cornerRadius = 5.0
        setGeocoder()
        
        // Checks if listing data is avaliable
        if let listing = listing {
            //Set navigation bar title to the listing title
            navigationItem.title = listing.title
            
            listingImageView.af_setImage(withURL: listing.photos[0])
            listingTitleLabel.text = listing.title
            listingDescriptionLabel.text = listing.description
            
            if let profileImageUrl = listing.seller.profileImageUrl {
                profileImageView.af_setImage(withURL: profileImageUrl)
            }
            
            profileNameLabel.text = listing.seller.name
            
            // Keeps the price on the image current with the highest bid
            ref?.child("listings").child(listing.listingID).observe(.value, with: { snapshot in
                let highestBidListingID = snapshot.childSnapshot(forPath: "winningBidId").value as! String
                var highestBidAmount = snapshot.childSnapshot(forPath: "startingPrice").value as! Double
                
                if !highestBidListingID.isEmpty {
                    highestBidAmount = snapshot.childSnapshot(forPath: "bids/\(highestBidListingID)/amount").value as! Double
                }
                
                self.listingCurrentPrice.text = "$\(String(format:"%.2f", highestBidAmount))"
            })
            
            // TODO: Implement ratings for sellers.
            profileRating.rating = 3
            
            for button in profileRating.ratingButtons{
                button.isUserInteractionEnabled = false
            }
        }
    }
    
    // MARK: - MKMapView
    
    // Set a new geocoder for annotating the lister's location on the mapView.
    // TODO: Set the location string to the users actual location when geo-location is setup.
    func setGeocoder() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString("34 Bridlecreek Pk Sw, Calgary AB, Canada T2Y3N6", completionHandler: { placemarks, error in
            if error != nil {
                return
            }
            
            // Get the placemarks, and always take the first mark.
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                
                if let location = placemark.location {
                    self.setLocationOverlay(location.coordinate)
                    
                    // Set the zoom level.
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 750, 750)
                    self.mapView.setRegion(region, animated: false)
                }
            }
        })
    }
    
    // Create a circular map overlay for seller's location.
    func setLocationOverlay(_ center: CLLocationCoordinate2D) {
        let radius = CLLocationDistance(150)
        let overlay = MKCircle(center: center, radius: radius)
        
        mapView.add(overlay)
    }
    
    // MARK: - Bidding System
    
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
                self.addBidToUserBiddingProfile(listingKey: listingRef.key)
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
    
    //Function add the listing key of the item the user is bidding on to the db in their user data
    func addBidToUserBiddingProfile(listingKey: String) {
        guard let userId = FIRAuth.auth()?.currentUser?.uid else {
            alertUserNotLoggedIn()
            return
        }
        
        let biddingListingType = ListingType.bidding.description
        ref?.child("users").child(userId).child("listings").child(biddingListingType).child(listingKey).setValue(true)
    }
    
    // MARK: - UIResponder
    
    // Optional. Tells the responder when one or more fingers touch down in a view or window.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        textField.resignFirstResponder()
    }
    
    // MARK: - Actions
    
    // Respond to tappedBidButton tap.
    @IBAction func tappedBidButton(_ sender: UIButton) {
        textField.becomeFirstResponder()
    }
    
    // Respond to placeBidButton tap.
    func tappedPlaceBid() {
        //Check if user is logged in
        if let user = FIRAuth.auth()?.currentUser {
            // Check if the user placed a bid value in the text field
            if let bidAmount = Double(toolbarTextField.text!) {
                
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
                        } else {
                            // TODO: Let the user know they bid lower than the required amount
                        }
                    }
                })
            }
        } else {
            alertUserNotLoggedIn()
        }
        
        view.endEditing(true)
        textField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension ListingDetailViewController: UITextFieldDelegate {
    
    // Optional. Asks the delegate if editing should begin in the specified text field.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.barStyle = UIBarStyle.default
        
        toolbarTextField = TextField()
        toolbarTextField.placeholder = "Enter your price"
        toolbarTextField.backgroundColor = UIColor.lightText
        toolbarTextField.keyboardType = .numberPad
        toolbarTextField.layer.cornerRadius = 5.0
        toolbarTextField.sizeToFit()
        
        keyboardToolbar.setItems([
            UIBarButtonItem(customView: toolbarTextField),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Place Bid", style: .plain, target: self, action: #selector(tappedPlaceBid))
            ], animated: false)
        
        keyboardToolbar.isUserInteractionEnabled = true
        keyboardToolbar.sizeToFit()
        textField.inputAccessoryView = keyboardToolbar
        
        return true
    }
}

// MARK: - MKMapViewDelegate protocol
extension ListingDetailViewController: MKMapViewDelegate {
    
    // Optional. Asks the delegate for a renderer object to use when drawing the specified overlay.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = ColorPalette.bidblue.withAlphaComponent(0.5)
        circleRenderer.strokeColor = ColorPalette.bidblue
        circleRenderer.lineWidth = 1.0
        
        return circleRenderer
    }
}
