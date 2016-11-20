//
//  CameraViewController.swift
//  Lulu
//
//  Created by Patrick Czeczko, Shreya Chopra on 2016-11-08.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase


class CameraViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var addPhotosImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descTextArea: UITextView!
    @IBOutlet weak var startingPriceTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var postButtonOutlet: UIButton!
    
    // MARK: - Properties
    var tempUserData: User!
    var firebaseDBReference: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup reference to the database
        firebaseDBReference = FIRDatabase.database().reference()
        
        // Establish border colouring and corners on textview and button to matach styles
        descTextArea.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        descTextArea.layer.borderWidth = 1.0
        descTextArea.layer.cornerRadius = 5.0
        postButtonOutlet.layer.cornerRadius = 5.0
        
        // Setup appropriate delegates
        descTextArea.delegate = self
        titleTextField.delegate = self
        startingPriceTextField.delegate = self
        endDateTextField.delegate = self
        
        // Setup toolbar to appear above numebrica keybaord when setting price
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
        
        //set up date picker
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.frame = CGRect(x: 10, y:50, width: self.view.frame.width, height: 200)
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        
        datePicker.addTarget(self, action: #selector(CameraViewController.datePickerValueChanged(_:)), for: .valueChanged)
        self.view.addSubview(datePicker)
        
        // Setup toolbar to be above keybaord on text area
        let descToolbar = UIToolbar()
        descToolbar.barStyle = UIBarStyle.default
        descToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CameraViewController.cancelPressed)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(CameraViewController.donePressed))
        ]
        
        descToolbar.sizeToFit()
        descTextArea.inputAccessoryView = descToolbar
    }
    
    func donePressed(){
        view.endEditing(true)
    }
    func cancelPressed(){
        view.endEditing(true) // or do something
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //changes date and time value in text field
    func datePickerValueChanged(_ sender: UIDatePicker){
        
        //creating date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        //set date format
        dateFormatter.dateFormat = "MM/dd/YYYY hh:mm a"
        
        //Apply date format
        endDateTextField.text = dateFormatter.string(from: sender.date)
        
    }
    
    // Function handles the steps required to take the data on the view and place it into the DB
    @IBAction func postButtonClicked(_ sender: AnyObject) {
        // Disable post button while uploading information
        self.postButtonOutlet.isEnabled = false
        
        let listingTitle = titleTextField.text
        let startPrice = Int(startingPriceTextField.text!)
        let endDate = endDateTextField.text
        let desc = descTextArea.text
        
        let listingDetails:NSMutableDictionary = [
            "title": listingTitle ?? "Test",
            "startPrice": startPrice ?? -1,
            "endDate": endDate ?? "endDate",
            "desc": desc ?? "desc",
            "endDate": " ",
            "seller":" ",
            "buyoutPrice": " ",
            "currentPrice": startPrice ?? -1
        ]
        
        let dbreference = firebaseDBReference.child("listings").childByAutoId()
        
        let image = (addPhotosImage.image)!
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        
        uploadImageToFirebase(data: imageData!, listingData: listingDetails, dbreference: dbreference)
    }
    
    // Handles uploading the image to firebase upon which the listing details are sent to the database
    func uploadImageToFirebase(data: Data, listingData: NSMutableDictionary, dbreference: FIRDatabaseReference) {
        let dbrefString = String(dbreference.description().characters.suffix(20))
        
        let storageRef = FIRStorage.storage().reference(withPath: "listingImages/\(dbrefString).jpg")
        let uploadMetadata = FIRStorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        var downloadURL:String!
        
        storageRef.put(data as Data, metadata: uploadMetadata) { (metadata, error) in
            if (error != nil) {
                // Uh-oh, an error occurred!
                // TODO: deal with this in some way
            } else {
                downloadURL = (metadata!.downloadURL()?.absoluteString)!
                
                listingData.addEntries(from: ["imageURL": [downloadURL]])
                
                self.uploadListingToDB(listingData, dbreference: dbreference)
            }
        }
    }
    
    // Places the listing details in the DB and resets the fields on the page
    func uploadListingToDB(_ listingDetails: NSMutableDictionary, dbreference: FIRDatabaseReference) {
        dbreference.setValue(listingDetails) { (error, ref) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
                // TODO: deal with this in some way
            } else {
                self.titleTextField.text = ""
                self.startingPriceTextField.text = ""
                self.endDateTextField.text = ""
                self.descTextArea.text = ""
                self.addPhotosImage.image = UIImage(named: "addPhotoImage")
                self.postButtonOutlet.isEnabled = true
            }
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
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
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
