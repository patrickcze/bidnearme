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
import GeoFire
import CoreLocation
import AddressBookUI

class ListingDetailViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var listingImageView: UIImageView!
    @IBOutlet weak var listingTitleLabel: UILabel!
    @IBOutlet weak var listingDescriptionLabel: UILabel!
    @IBOutlet weak var listingPriceTag: UIView!
    @IBOutlet weak var listingCurrentPrice: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileRating: RatingControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeBidButton: UIButton!
    
    // MARK: - Properties
    var listing: Listing?
    var textField: UITextField! = UITextField()
    var toolbarTextField: UITextField! = UITextField()
    var ref: FIRDatabaseReference?
    var loggedInUser: FIRUser?
    
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
      
        setTextFields()
        placeBidButton.backgroundColor = ColorPalette.bidBlue
        
        // Get logged in user.
        loggedInUser = FIRAuth.auth()?.currentUser
      
        //Get a reference to the firebase db and storage
        ref = FIRDatabase.database().reference()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        placeBidButton.backgroundColor = ColorPalette.bidBlue
        listingPriceTag.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        profileHeightConstraint.constant = view.frame.width * 0.75
        
        mapView.layer.cornerRadius = 5.0
        setGeocoder()
        
        // Checks if listing data is avaliable
        if let listing = listing {
            //Set navigation bar title to the listing title
            navigationItem.title = listing.title
            
            listingImageView.af_setImage(withURL: listing.imageUrls[0])
            listingTitleLabel.text = listing.title
            listingDescriptionLabel.text = listing.description
            
            getUserById(userId: listing.sellerId){ (seller) in
                if let profileImageUrl = seller.profileImageUrl {
                    self.profileImageView.af_setImage(withURL: profileImageUrl)
                }
                self.profileNameLabel.text = seller.name
            }
            
            // Keeps the price on the image current with the highest bid
            ref?.child("listings").child(listing.listingId).observe(.value, with: { snapshot in
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
            
            // Add chat button to navigation bar if the logged-in user is not the seller of this listing.
            if listing.sellerId != loggedInUser?.uid {
                // Add chat bar button item.
                let chatBarButtonItem = UIBarButtonItem(
                    title: "Chat",
                    style: .plain,
                    target: self,
                    action: #selector(didTapChatButton(_:))
                )
                navigationItem.setRightBarButtonItems([chatBarButtonItem], animated: false)
            }
        }
    }
  
    // Logic for textfield and toolbarTextField.
    func setTextFields() {
      textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
      textField.keyboardType = .numberPad
      textField.delegate = self
      view.addSubview(textField)
      
      let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboards))
      view.addGestureRecognizer(tap)
      
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    // Retrieve item's location from geohash and display on map
    func setGeocoder() {
        let geoCoder = CLGeocoder()
        guard let listingId = listing?.listingId else { fatalError("Listing must be defined for this page") }
        
        //initialize reference to geoFire
        let geofireRef = FIRDatabase.database().reference().child("location")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        
        geoFire!.getLocationForKey(listingId, withCallback: { (location, error) in
            if (error != nil) {
                print("An error occurred getting the location for \(listingId)/: \(error?.localizedDescription)")
            } else if (location != nil) {
                print("Location for \(listingId)/ is [\(location!.coordinate.latitude), \(location!.coordinate.longitude)]")
                
                let long = location!.coordinate.longitude
                let lat = location!.coordinate.latitude
                let loc = CLLocation(latitude: lat, longitude: long)
                
                geoCoder.reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) -> Void in
                    print(loc)
                    
                    if error != nil {
                        print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
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
            } else {
                print("GeoFire does not contain a location for \(listingId)")
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
        guard let userId = loggedInUser?.uid else {
            alertUserNotLoggedIn()
            return
        }
        
        let biddingListingType = ListingType.bidding.description
        ref?.child("users").child(userId).child("listings").child(biddingListingType).child(listingKey).setValue(true)
    }
    
    /**
     Display chat messages in a separate view controller.
     */
    func displayChat(chat: Chat?) {
        self.performSegue(withIdentifier: "ShowChatMessages", sender: chat)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowChatMessages" {
            guard let loggedInUser = loggedInUser else {
                // Cannot show chats if the user has not been retrieved.
                alertUserNotLoggedIn()
                return
            }
            
            if let chat = sender as? Chat {
                let chatMessagesViewController = segue.destination as! ChatMessagesViewController
                
                // Set required fields for JSQMessagesViewController to identify the current user.
                chatMessagesViewController.senderId = loggedInUser.uid
                chatMessagesViewController.senderDisplayName = loggedInUser.displayName
                chatMessagesViewController.chat = chat
            }
        }
    }
  
    // MARK: - Actions
    
    // Respond to tappedBidButton tap.
    @IBAction func tappedBidButton(_ sender: UIButton) {
        textField.becomeFirstResponder()
    }
    
    /**
     Respond to Chat navigation bar button being pressed.
     If there is an existing chat between the listing and the bidder, then get that chat and display it.
     Otherwise, create a new chat and display it.
     */
    func didTapChatButton(_ sender: UIBarButtonItem) {
        guard let bidderId = loggedInUser?.uid else {
            alertUserNotLoggedIn()
            return
        }
        guard let listing = listing else { fatalError("Listing must be defined for this page") }
        guard let sellerId = listing.sellerId else { fatalError("SellerId must be defined for a listing.") }
        
        // TODO: Disable button to prevent clicking twice by accident and creating chat twice before chat is displayed.
        
        // Check if listing has a chat for this bidder. If so, just retrieve it. Otherwise, create one.
        if let listingBidderChatId = listing.bidderChats[bidderId] {
            getChatById(listingBidderChatId, completion: displayChat)
        } else {
            // Write chat to database.
            writeChat(listingId: listing.listingId, sellerId: sellerId, bidderId: bidderId, withTitle: listing.title) { (chat) in
                // Add bidder to chat ID mapping to this listing. This will get updated server-side too.
                self.listing?.bidderChats[bidderId] = chat?.uid
                self.displayChat(chat: chat)
            }
        }
    }
    
    // Respond to placeBidButton tap.
    func tappedPlaceBid() {
        guard let loggedInUserId = self.loggedInUser?.uid else {
            self.alertUserNotLoggedIn()
            return
        }
        
        // Check if the user placed a bid value in the text field
        if let bidAmount = Double(toolbarTextField.text!) {
                
            let listingId = listing?.listingId
            let listingRef = ref?.child("listings").child(listingId!)
                
            //Check if bid table exists
            listingRef?.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild("bids") {
                    //Checks that the desired bid is the highest
                    if self.isHighestBid(bidAmount: bidAmount, listingSnapshot: snapshot) {
                        let bidObject: [String : Any] = [
                            "amount": bidAmount,
                            "bidderId": loggedInUserId,
                            "createdTimestamp" : FIRServerValue.timestamp()
                        ]
                            
                        self.placeBidInDB(bidObject: bidObject, listingRef: listingRef!)
                    } else {
                        // TODO: Let the user know they bid lower than the required amount
                    }
                }
            })
        }
        dismissKeyboards()
    }
  
    // Dismiss textfield keyboards from the view in order.
    func dismissKeyboards() {
      guard toolbarTextField.isFirstResponder else {
        return
      }
      
      view.endEditing(true)
      toolbarTextField.resignFirstResponder()
      textField.resignFirstResponder()
    }
  
    // MARK: - Observers
  
    // Observe NSNotification.Name.UIKeyboardWillShow
    func keyboardWillAppear(notification: NSNotification) {
      guard toolbarTextField != nil, !toolbarTextField.isFirstResponder else {
        return
      }
    
      toolbarTextField.becomeFirstResponder()
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
        circleRenderer.fillColor = ColorPalette.bidBlue.withAlphaComponent(0.5)
        circleRenderer.strokeColor = ColorPalette.bidBlue
        circleRenderer.lineWidth = 1.0
        
        return circleRenderer
    }
}
