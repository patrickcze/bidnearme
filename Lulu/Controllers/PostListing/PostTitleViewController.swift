//
//  PostTitleViewController.swift
//  Lulu
//
//  Created by Scott Campbell on 12/3/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import GeoFire
import CoreLocation
import AddressBookUI

class PostTitleViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    
    // MARK: - Properties
    var listingPhoto: UIImage!
    
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.returnKeyType = .next
        descriptionTextField.returnKeyType = .next
        postalCodeTextField.returnKeyType = .go
        
        title = "Post Listing"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
        // Adding an observer for the keyboardWillAppear function. It will be triggered when the application is notified that the keyboard (any) has been shown. It works much like registering a gesture recognizer, but it listens to all registered UIKeyboardWillShow notifications instead of a single gesture.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        nextButton.layer.cornerRadius = 5.0
    }
    
    // MARK: - Observers
    
    // The first 4 lines of this function grab the frame height for the view that registered the notification (in this case it's a UIKeyboardWillShow). This particular line grabs the registering dictionary, which I downcast to AnyObject using the appropriate key. Then i can use that object's frame (i.e the height of the keyboard) to determine the offset for animating the "next" button, instead of hardcoding that offset to the approx height of the keyboard.
    func keyboardWillAppear(notification: NSNotification) {
        let info = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        
        guard let rawFrame = value.cgRectValue else {
            return
        }
        
        let keyboardHeight = view.convert(rawFrame, from: nil).height
        
        if titleTextField.isFirstResponder || descriptionTextField.isFirstResponder || postalCodeTextField.isFirstResponder{
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
    
    // Respond to next button tap.
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        
        //convert postal code to coordinates and save
        forwardGeocoding(postalCode: postalCodeTextField.text!)
        
        //Segue to next screen
        segueToSignUpPassword()
    }
    
    
    
    // MARK: - Navigation
    
    // Segue to the next step in the wizard.
    func segueToSignUpPassword() {
        if titleTextField.isFirstResponder || descriptionTextField.isFirstResponder || postalCodeTextField.isFirstResponder{
            dismissKeyboard()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.performSegue(withIdentifier: "WizardStepThree", sender: self)
            }
        } else {
            performSegue(withIdentifier: "WizardStepThree", sender: self)
        }
    }
    
    // Notifies the view controller that a segue is about to be performed.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WizardStepThree" {
            let destinationController = segue.destination as! PostPriceViewController
            destinationController.listingPhoto = listingPhoto
            destinationController.listingTitle = titleTextField.text
            destinationController.listingDescription = descriptionTextField.text
            destinationController.listingPostalCode = postalCodeTextField.text
        }
    }
}

// MARK: - UITextFieldDelegate protocol
extension PostTitleViewController: UITextFieldDelegate {
    
    // Optional. Asks the delegate if the text field should process the pressing of the return button.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = textField.superview?.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
            segueToSignUpPassword()
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

