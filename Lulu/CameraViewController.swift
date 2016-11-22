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

class CameraViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var addPhotosImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextArea: UITextView!
    @IBOutlet weak var startingPriceTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var postListingButton: UIButton!
    
    // MARK: - Properties
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    
    let auctionDurationPickerArray = [ListingTimeInterval.oneDay.description,
                                      ListingTimeInterval.threeDays.description,
                                      ListingTimeInterval.fiveDays.description,
                                      ListingTimeInterval.sevenDays.description,
                                      ListingTimeInterval.tenDays.description,
                                      ListingTimeInterval.fourteenDays.description]
    
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
        
        // Set up appropriate delegates
        descriptionTextArea.delegate = self
        titleTextField.delegate = self
        startingPriceTextField.delegate = self
        endDateTextField.delegate = self
        
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
    }
    
    // returns the number of 'columns' to display.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1;
    }
    
    // returns the # of rows in each component.
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return auctionDurationPickerArray.count
        
    }
    
    //places text in text field
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        endDateTextField.text = auctionDurationPickerArray[row]
    }
    
    // title for each row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return auctionDurationPickerArray[row]
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
        
        // Prepare and upload listing image to Firebase Storage.
        // TODO: Throw errors.
        guard let image = addPhotosImage.image else {
            // TODO: Display error message stating that >= 1 images are needed.
            return
        }
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
            // TODO: Display error message about file format.
            return
        }
        
        // Upload the image and write the listing if the image was successfully uploaded.
        uploadImage(imageData: imageData) { (imageUrl) in
            
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
                "bids": [String: Any](),
                "imageUrls": [imageUrlString]
            ]
            
            // TODO: Allow user input for auction duration.
            self.writeListing(listing, withAuctionDuration: ListingTimeInterval.sevenDays)
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
     */
    func uploadImage(imageData: Data, completion: @escaping (URL?) -> Void) {
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
    
    // Places the listing details in the DB and resets the fields on the page
    func writeListing(_ listing: [String: Any], withAuctionDuration: ListingTimeInterval) {
        let newListingRef = ref.child("listings").childByAutoId()
        
        // Write the listing to the database. Firebase sets the createdTimestamp for use below.
        newListingRef.setValue(listing) { (error, newRef) in
            if error != nil {
                // TODO: deal with this in some way
            }
            self.resetListingViews()
        }
        
        // Sets the listing's auction end time based on createdTimestamp and duration.
        // This is necessary as createdTimestamp is written by Firebase server-side.
        newListingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let listing = snapshot.value as? [String: Any]
            guard let createdTimestamp = listing?["createdTimestamp"] as? Int else {
                // TODO: Handle error with retrieving created timestamp value.
                return
            }
            
            // Update the listing's timestamp based on the duration.
            let auctionEndTimestamp = self.getLaterTimestamp(time: withAuctionDuration, from: createdTimestamp)
            newListingRef.updateChildValues(["auctionEndTimestamp": auctionEndTimestamp])
        }) { (error) in
            // TODO: Handle error with updating.
        }
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

// MARK: - UITextViewDelegate
extension CameraViewController: UITextViewDelegate {
}
