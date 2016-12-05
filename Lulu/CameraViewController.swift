//
//  CameraViewController.swift
//  Lulu
//
//  Created by Patrick Czeczko, Shreya Chopra on 2016-11-08.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import GeoFire
import CoreLocation
import AddressBookUI


class CameraViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var addPhotosImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextArea: UITextView!
    @IBOutlet weak var startingPriceTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var postListingButton: UIButton!
    @IBOutlet weak var postalCodeTextField: UITextField!
    
    // MARK: - Properties
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var auctionDurationPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize reference to the Firebase database.
        ref = FIRDatabase.database().reference()
        
        // Initialize reference to the Firebase storage.
        storageRef = FIRStorage.storage().reference()

        // Establish border colouring and corners on textview and button to matach styles
        descriptionTextArea.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        descriptionTextArea.layer.borderWidth = 1.0
        descriptionTextArea.layer.cornerRadius = 5.0
        postListingButton.layer.cornerRadius = 5.0
        
        //Set button colour to correct blue colour
        postListingButton.backgroundColor = ColorPalette.bidBlue
        
        // Set up appropriate delegates
        descriptionTextArea.delegate = self
        titleTextField.delegate = self
        startingPriceTextField.delegate = self
        endDateTextField.delegate = self
        postalCodeTextField.delegate = self
        
        //set up picker to delegate
        auctionDurationPicker.delegate = self
        
        //set up picker to datasource
        auctionDurationPicker.dataSource = self
        
        //set up input view of end date text field to picker
        endDateTextField.inputView = auctionDurationPicker
        
        // Set up toolbar to appear above numerical keyboard when setting price
        let numberToolbar = UIToolbar()
        numberToolbar.barStyle = UIBarStyle.default
        
        numberToolbar.setItems([
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CameraViewController.cancelPressed)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(CameraViewController.donePressed))
            ], animated: false)
        
        numberToolbar.isUserInteractionEnabled = true
        numberToolbar.sizeToFit()
        
        startingPriceTextField.inputAccessoryView = numberToolbar
        
        // Setup toolbar to be above keybaord on text area
        let descriptionToolbar = UIToolbar()
        descriptionToolbar.barStyle = UIBarStyle.default
        descriptionToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CameraViewController.cancelPressed)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(CameraViewController.donePressed))
        ]
        
        descriptionToolbar.sizeToFit()
        descriptionTextArea.inputAccessoryView = descriptionToolbar
        
        // Setup toolbar to be above keybaord on text area
        let durationPickerToolbar = UIToolbar()
        durationPickerToolbar.barStyle = UIBarStyle.default
        durationPickerToolbar.items = [
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(CameraViewController.donePressed))
        ]
        
        durationPickerToolbar.sizeToFit()
        endDateTextField.inputAccessoryView = descriptionToolbar
    }

    func donePressed(){
        view.endEditing(true)
    }
    
    func cancelPressed(){
        view.endEditing(true) // or do something
    }
    
    func resetListingViews() {
        titleTextField.text = ""
        startingPriceTextField.text = ""
        endDateTextField.text = ""
        descriptionTextArea.text = ""
        addPhotosImage.image = UIImage(named: "addPhotoImage")
        postListingButton.isEnabled = true
    }
    
    // TODO: Allow user selection for auction duration.
    // Function handles the steps required to take the listing data on the view and place it into the DB
    @IBAction func postButtonClicked(_ sender: AnyObject) {
        
        // Disable post button while uploading information
        self.postListingButton.isEnabled = false
        
        guard let sellerId = FIRAuth.auth()?.currentUser?.uid else {
            // TODO: Indicate that a user is logged in.
            return
        }
        
        guard let title = titleTextField.text else {
            // TODO: Indicate that a title is necessary
            return
        }
        
        guard let startingPrice = Double(startingPriceTextField.text!), startingPrice >= 0.0 else {
            // TODO: Indicate that a start price is necessary and must be >= 0 amount.
            return
        }
        
        guard let description = descriptionTextArea.text else {
            // TODO: Indicate that a description is needed.
            return
        }

        //set latitude and longitude location with callback
        forwardGeocoding(postalCode: postalCodeTextField.text!)
        
        // assign value of selected row as picked value
        let auctionDurationPickerSelectedRow = auctionDurationPicker.selectedRow(inComponent: 0)
        guard auctionDurationPickerSelectedRow < ListingTimeInterval.allValues.count else {
            fatalError("Selected row is does not exist in ListingTimeInterval")
        }
        
        // saving value of selected row from picker for database
        let auctionDuration = ListingTimeInterval.allValues[auctionDurationPickerSelectedRow]
 
        // Prepare and upload listing image to Firebase Storage.
        // TODO: Throw errors.
        guard let image = addPhotosImage.image else {
            // TODO: Display error message stating that >= 1 images are needed.
            return
        }
        
        // Upload the image and write the listing if the image was successfully uploaded.
        uploadImage(image: image) { (imageUrl) in
            
            guard let imageUrlString = imageUrl?.absoluteString else {
                // TODO: Display error message about upload failure.
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
                "imageUrls": [imageUrlString]
            ]
            
            // TODO: Allow user input for auction duration.
            self.writeListing(listing) { (listingRef) in
                self.addListingToUserSelling(listingId: listingRef.key, userId: sellerId)
                self.updateListingAuctionEnd(listingRef: listingRef, withAuctionDuration: auctionDuration)
                self.resetListingViews()
            }
        }
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
    
    /**
     Converts the postal code to latitude and longitude and saves the coordinate
    
     -parameter postalCode: postal code of the pickup location to be converted into coordinates
    */
    
    func forwardGeocoding(postalCode: String){
        CLGeocoder().geocodeAddressString(postalCode, completionHandler: {(placemarks, error) in
            if error != nil {
                print(error)
                return
            }
            
            //initialize reference to geoFire
            let geofireRef = FIRDatabase.database().reference()
            let geoFire = GeoFire(firebaseRef: geofireRef)
            
            if (placemarks?.count)! > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                geoFire!.setLocation(CLLocation(latitude: coordinate!.latitude, longitude: coordinate!.longitude), forKey: "firebase-hq") { (error) in
                    if (error != nil) {
                        print("An error occured: \(error)")
                    } else {
                        print("Saved location successfully!")
                    }
                }
            }
        })
    }
    
}




// MARK: - UIImagePickerControllerDelegate
extension CameraViewController: UIImagePickerControllerDelegate {
    //Creates image view
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let alert:UIAlertController = UIAlertController.init(title: "Your choice", message: "Take a photo or use an existing one?", preferredStyle: .actionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        alert.addAction(cancelActionButton)
        
        let photoLibraryButton: UIAlertAction = UIAlertAction(title: "Select from Photo Library", style: .default) { action -> Void in
            // UIImagePickerController is a view controller that lets a user pick media from their photo library.
            let imagePickerController = UIImagePickerController()
            
            // Only allow photos to be picked, not taken.
            imagePickerController.sourceType = .photoLibrary
            
            // Make sure ViewController is notified when the user picks an image.
            imagePickerController.delegate = self
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
        alert.addAction(photoLibraryButton)
        
        let cameraButton: UIAlertAction = UIAlertAction(title: "Take a Photo", style: .default) { action -> Void in
            // UIImagePickerController is a view controller that lets a user pick media from their photo library.
            let imagePickerController = UIImagePickerController()
            
            // Only allow photos to be picked, not taken.
            imagePickerController.sourceType = .camera
            
            // Make sure ViewController is notified when the user picks an image.
            imagePickerController.delegate = self
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
        alert.addAction(cameraButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            addPhotosImage.image = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
 
    
}

// MARK: - UINavigationControllerDelegate
extension CameraViewController: UINavigationControllerDelegate {
}

// MARK: - UITextViewDelegate
extension CameraViewController: UITextViewDelegate {
}

// MARK: - UIPickerViewDelegate and UIPickerViewDelegate
extension CameraViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
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
        endDateTextField.text = ListingTimeInterval.allValues[row].description
    }
    
}

