//
//  PostListingViewController.swift
//  Lulu
//
//  Created by Scott Campbell on 12/3/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class PostListingViewController: UIViewController {
  
  // MARK: - Outlets
  @IBOutlet weak var addPhotoImage: UIImageView!
  @IBOutlet weak var nextButton: UIButton!
  
  // Do any additional setup after loading the view.
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Post Listing"
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
    addPhotoImage.addGestureRecognizer(tap)
    
    nextButton.layer.cornerRadius = 5.0
  }
  
  // MARK: - Actions
  
  @IBAction func unwindToRoot(segue: UIStoryboardSegue) {
    addPhotoImage.image = UIImage(named: "addPhotoImage")
  }
  
  // MARK: - Navigation
  
  // Notifies the view controller that a segue is about to be performed.
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "WizardStepTwo" {
      let destinationController = segue.destination as! PostTitleViewController
      destinationController.listingPhoto = addPhotoImage.image
    }
  }
}

// MARK: - UIImagePickerControllerDelegate protocol
extension PostListingViewController: UIImagePickerControllerDelegate {
  
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
      addPhotoImage.image = image
    }
    
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: - UINavigationControllerDelegate protocol
extension PostListingViewController: UINavigationControllerDelegate {}
