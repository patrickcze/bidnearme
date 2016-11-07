//
//  CameraViewController.swift
//  Lulu
//
//  Created by shreya on 2016-10-31.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    //MARK Outlets
    @IBOutlet weak var addPhotosImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descTextArea: UITextView!
    @IBOutlet weak var startingPriceTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var postButtonOutlet: UIButton!
    
    //MARK properties
    var tempUserData: User!
    
    var ref: FIRDatabaseReference!
    
    var user: User? {
        didSet {
//            if let user = user {
//                usersNameLabel.text = user.firstName + " " + user.lastName
//                userImage.image = user.profileImage
//                ratingLabel.text = String(user.rating) + " Stars"
//                yearLabel.text = "Member Since " + String(user.memberSince)
//                repliesInLabel.text = "Replies " + user.replyingHabit
//            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        descTextArea.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        descTextArea.layer.borderWidth = 1.0
        descTextArea.layer.cornerRadius = 5.0
        
        descTextArea.delegate = self
        
        postButtonOutlet.layer.cornerRadius = 5.0
        
        titleTextField.delegate = self
        startingPriceTextField.delegate = self
        endDateTextField.delegate = self
        
        let numberToolbar = UIToolbar()
        numberToolbar.barStyle = UIBarStyle.default
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(CameraViewController.donePressed))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CameraViewController.cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        numberToolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        numberToolbar.isUserInteractionEnabled = true
        numberToolbar.sizeToFit()
        
        startingPriceTextField.inputAccessoryView = numberToolbar
    }
    
    func donePressed(){
        view.endEditing(true)
    }
    func cancelPressed(){
        view.endEditing(true) // or do something
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Creates image view ,
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        print("Tapped")
        
        let alert:UIAlertController = UIAlertController.init(title: "Your choice", message: "Take a photo or use an existing one?", preferredStyle: .actionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        alert.addAction(cancelActionButton)
        
        let photoLibraryButton: UIAlertAction = UIAlertAction(title: "Select from Photo Library", style: .default) { action -> Void in
            print("photoLibraryButton")
            
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
            print("cameraButton")
            
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
        else{}
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Hide the keybaord
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    //Save data entered
    @IBAction func postButtonClicked(_ sender: AnyObject) {
        print("Post item")
        
        let listingTitle = titleTextField.text
        let startPrice = Int(startingPriceTextField.text!)
        let endDate = endDateTextField.text
        let desc = descTextArea.text
        let imageURLs:NSArray = ["https://firebasestorage.googleapis.com/v0/b/lulu-c1315.appspot.com/o/listingImages%2FbluePlaceholder.png?alt=media&token=f95aa419-b766-4f3f-bad3-9a86cc9e7028"]
        
        let listingDetails:NSDictionary = [
            "title": listingTitle ?? "Test",
            "startPrice": startPrice ?? -1,
            "endDate": endDate ?? "endDate",
            "desc": desc ?? "desc",
            "imageURL": imageURLs,
            "endDate": " ",
            "seller":" ",
            "buyoutPrice": " ",
            "currentPrice": startPrice ?? -1
        ]

        
        ref.child("listings").childByAutoId().setValue(listingDetails) { (error, ref) -> Void in
            if (error != nil) {
                print("ERROR")
            } else {
                print("Success")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
