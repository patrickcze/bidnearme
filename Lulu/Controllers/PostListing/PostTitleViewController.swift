//
//  PostTitleViewController.swift
//  Lulu
//
//  Created by Scott Campbell on 12/3/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class PostTitleViewController: UIViewController {
  
  // MARK: - Outlets
  @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var descriptionTextField: UITextField!
  
  // MARK: - Properties
  var listingPhoto: UIImage!
  
  // Do any additional setup after loading the view.
  override func viewDidLoad() {
    super.viewDidLoad()
    
    titleTextField.returnKeyType = .next
    descriptionTextField.returnKeyType = .go
    
    title = "Post Listing"
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
    
    nextButton.layer.cornerRadius = 5.0
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
    
    if titleTextField.isFirstResponder || descriptionTextField.isFirstResponder {
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
  @IBAction func nextButtonClicked(_ sender: UIButton) {
    segueToSignUpPassword()
  }
  
  // MARK: - Navigation
  
  // Segue to the next step in the wizard.
  func segueToSignUpPassword() {
    if titleTextField.isFirstResponder || descriptionTextField.isFirstResponder {
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

