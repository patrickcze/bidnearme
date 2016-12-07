//
//  PostPriceViewController.swift
//  Lulu
//
//  Created by Scott Campbell on 12/4/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import GeoFire
import CoreLocation
import AddressBookUI

class PostPriceViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    
    // MARK: - Properties
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var listingPhoto: UIImage!
    var listingTitle: String!
    var listingDescription: String!
    var auctionDurationPicker = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference()
        
        priceTextField.returnKeyType = .next
        title = "Post Listing"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        postButton.layer.cornerRadius = 5.0
        postButton.backgroundColor = ColorPalette.bidBlue
        
        setupAuctionPicker()
    }
    
    func setupAuctionPicker() {
        auctionDurationPicker.delegate = self
        auctionDurationPicker.dataSource = self
        dateTextField.inputView = auctionDurationPicker
    }
    
    // MARK: - Observers
    
    // Observe NSNotification.Name.UIKeyboardWillShow
    func keyboardWillAppear(notification: NSNotification) {
        let info = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        
        guard let rawFrame = value.cgRectValue else {
            return
        }
        
        let keyboardHeight = view.convert(rawFrame, from: nil).height
        
        if priceTextField.isFirstResponder || dateTextField.isFirstResponder || postalCodeTextField.isFirstResponder {
            animateNextButton(keyboardHeight)
        }
    }
    
    // Animate stack view constraints.
    func animateNextButton(_ keyboardHeight: CGFloat) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                self.stackViewHeight.constant = keyboardHeight - 36.0
        },
            completion: nil
        )
    }
    
    // Dismiss textfield keyboard.
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
    // Respond to next button tap.
    @IBAction func postButtonClicked(_ sender: UIButton) {
        dismissKeyboard()
        
        // Disable post button while uploading information
        self.postButton.isEnabled = false
        
        guard let sellerId = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        guard let title = listingTitle, let description = listingDescription, let image = listingPhoto, let postalCode = postalCodeTextField.text else {
            return
        }
        
        guard let startingPrice = Double(priceTextField.text!), startingPrice >= 0.0 else {
            return
        }
        
        // assign value of selected row as picked value
        let auctionDurationPickerSelectedRow = auctionDurationPicker.selectedRow(inComponent: 0)
        
        guard auctionDurationPickerSelectedRow < ListingTimeInterval.allValues.count else {
            fatalError("Selected row does not exist in ListingTimeInterval")
        }
        
        //Convert user postal code into coordinate
        forwardGeocoding(postalCode: postalCode, itemListing: listingTitle) { (coordinate) in
            guard let latitude = coordinate.latitude as? Double else{
                //TODO: Deal with Error
                return
            }
            
            guard let longitude = coordinate.longitude as? Double else{
                //TODO: Deal with error
                return
            }
            
            // saving value of selected row from picker for database
            let auctionDuration = ListingTimeInterval.allValues[auctionDurationPickerSelectedRow]
            
            // Upload the image and write the listing if the image was successfully uploaded.
            self.uploadImage(image: image) { (imageUrl) in
                
                guard let imageUrlString = imageUrl?.absoluteString else {
                    return
                }
                
                let listing: [String: Any] = [
                    "sellerId": sellerId,
                    "title": title,
                    "startingPrice": startingPrice,
                    "description": description,
                    "createdTimestamp": FIRServerValue.timestamp(), // Firebase replaces this with its timestamp.
                    "auctionEndTimestamp": FIRServerValue.timestamp(), // Based on createdTimestamp. Updated after listing is posted.
                    "winningBidId": "",
                    "bids": "",
                    "imageUrls": [imageUrlString],
                    "location": [
                        "latitude": latitude,
                        "longitude": longitude
                    ]
                ]
                
                // TODO: Allow user input for auction duration.
                self.writeListing(listing) { (listingRef) in
                    self.addListingToUserSelling(listingId: listingRef.key, userId: sellerId)
                    self.updateListingAuctionEnd(listingRef: listingRef, withAuctionDuration: auctionDuration)
                    self.performSegue(withIdentifier: "UnwindToRoot", sender: self)
                }
            }
            
            
            print(coordinate)
        }
    }
    
    //coverts postal code to coordinates
    func forwardGeocoding(postalCode: String, itemListing: String!, completion: @escaping (CLLocationCoordinate2D) -> Void){
        CLGeocoder().geocodeAddressString(postalCode, completionHandler: {(placemarks, error) in
            if error != nil {
                print(error)
                return
            }
            
//            initialize reference to geoFire
//            let geofireRef = FIRDatabase.database().reference().child("location")
//            let geoFire = GeoFire(firebaseRef: geofireRef)
            
            if (placemarks?.count)! > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                
                guard let coordinate = location?.coordinate else {
                    return
                }
    
                completion(coordinate)
                
//                geoFire!.setLocation(CLLocation(latitude: coordinate!.latitude, longitude: coordinate!.longitude), forKey: "\(itemListing)") { (error) in
//                    if (error != nil) {
//                        print("An error occured: \(error)")
//                    } else {
//                        print("Saved location successfully!")
//                    }
//                }
            }
            
        })
        
    }
    
    /**
     Calculates a new timestamp based on the duration from an initial timestamp.
     
     - parameter time: Time interval to apply to the initial timestamp.
     - parameter from: Initial timestamp to add the time to.
     */
    func getLaterTimestamp(time: ListingTimeInterval, from initialTimestamp: Int) -> Int {
        return initialTimestamp + time.numberOfMilliseconds
    }
    
    /**
     Uploads an image to Firebase and returns its image URL if it was uploaded successfully.
     
     - parameter image: Image to upload.
     - parameter completion: Completion block to pass the new image's URL to.
     */
    func uploadImage(image: UIImage, completion: @escaping (URL?) -> Void) {
        // Convert image to JPEG. Any file type supported by UIImage will work.
        let imageData = UIImageJPEGRepresentation(image, 0.8)!
        let uuid = UUID().uuidString
        let imageRef = storageRef.child("listingImages/\(uuid).jpg")
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.put(imageData, metadata: metadata) { (metadata, error) in
            if error != nil {
                // Uh-oh, an error occurred!
                // TODO: deal with this in some way
            } else {
                completion(metadata!.downloadURL())
            }
        }
    }
    
    /**
     Writes the listing to the database.
     
     - parameter listing: Dictionary with listing information.
     - parameter completion: Completion block to pass the new listing reference to.
     */
    func writeListing(_ listing: [String: Any], completion: @escaping (FIRDatabaseReference) -> Void) {
        let listingRef = ref.child("listings").childByAutoId()
        
        // Write the listing to the database. Firebase sets the createdTimestamp for use below.
        listingRef.setValue(listing) { (error, newListingRef) in
            if error != nil {
                // TODO: deal with this in some way
            }
            completion(newListingRef)
        }
    }
    
    /**
     Sets the listing's auction end time based on createdTimestamp and duration.
     This is necessary as createdTimestamp is written by Firebase server-side.
     
     - parameter listingRef: Firebase Database reference to the listing.
     - parameter withAuctionDuration: Specified duration of the auction.
     */
    func updateListingAuctionEnd(listingRef: FIRDatabaseReference, withAuctionDuration: ListingTimeInterval) {
        
        listingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let listing = snapshot.value as? [String: Any]
            guard let createdTimestamp = listing?["createdTimestamp"] as? Int else {
                // TODO: Handle error with retrieving created timestamp value.
                return
            }
            
            // Update the listing's timestamp based on the duration.
            let auctionEndTimestamp = self.getLaterTimestamp(time: withAuctionDuration, from: createdTimestamp)
            listingRef.updateChildValues(["auctionEndTimestamp": auctionEndTimestamp])
            
        }) { (error) in
            // TODO: Handle error with updating.
        }
    }
    
    /**
     Adds the listing to the user's selling list.
     
     - parameter listingId: Listing ID of the listing to associate with the user.
     - parameter userId: User ID of the user to associate the listing to.
     */
    func addListingToUserSelling(listingId: String, userId: String) {
        let sellingListingType = ListingType.selling.description
        ref.child("users/\(userId)/listings/\(sellingListingType)/\(listingId)").setValue(true)
    }
}

// MARK: - UITextFieldDelegate protocol
extension PostPriceViewController: UITextFieldDelegate {
    
    // Optional. Asks the delegate if the text field should process the pressing of the return button.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = textField.superview?.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
            dismissKeyboard()
        }
        
        return false
    }
    
    // Optional. Tells the delegate that editing stopped for the specified text field.
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                self.stackViewHeight.constant = 12.0
        },
            completion: nil
        )
    }
}

// MARK: - UIPickerViewDelegate and UIPickerViewDelegate protocol
extension PostPriceViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    // returns the number of 'columns' to display.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1;
    }
    
    // returns the # of rows in each component.
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return ListingTimeInterval.allValues.count
    }
    
    // title for each row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ListingTimeInterval.allValues[row].description
    }
    
    //places text in text field
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dateTextField.text = ListingTimeInterval.allValues[row].description
    }
}
