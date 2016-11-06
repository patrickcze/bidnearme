//
//  CameraViewController.swift
//  Lulu
//
//  Created by shreya on 2016-10-31.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK Outlets
    @IBOutlet weak var addPhotosImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var startingPriceTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var starLabel: UILabel!//static
    @IBOutlet weak var memberSinceLabel: UILabel!//static
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var repliesInLabel: UILabel!
    @IBOutlet weak var takePicButton: UIButton!
    @IBOutlet weak var uploadPicButton: UIButton!
    @IBOutlet weak var dataTesterLabel: UILabel!
   
    
    //MARK properties
    
    
    var tempUserData: User!
    
    var user: User? {
        didSet {
            if let user = user {
                usersNameLabel.text = user.firstName + " " + user.lastName
                userImage.image = user.profileImage
                ratingLabel.text = String(user.rating) + " Stars"
                yearLabel.text = "Member Since " + String(user.memberSince)
                repliesInLabel.text = "Replies " + user.replyingHabit
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make user photo circular
        userImage?.layer.cornerRadius = userImage.frame.height/2
        userImage?.clipsToBounds = true
        
        // accessing data stored in the appDelegate
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let temp = appDelegate?.temporaryUser
        {
            tempUserData = temp
            userImage.image = tempUserData.profileImage
    
            
    
            
        }
        else // exception
        {
            print("CameraViewController: user NULL")
        }

        

        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func importImageButtonClicked(_ sender: AnyObject) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        image.allowsEditing = false
        self.present(image, animated: true)
        {
            //After it is complete
        }
    }
    
    @IBAction func takePhotoButtonClicked(_ sender: AnyObject)
    {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.camera
        
        image.allowsEditing = false
        self.present(image, animated: true)
        {
            //after it is complete
        }
    }
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            addPhotosImage.image = image
        }
        else
        {
            //Error message
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //Save data entered
    @IBAction func postButtonClicked(_ sender: AnyObject) {
        /*
        let defaults = UserDefaults.standard
        
        defaults.set(addPhotosImage.image, forKey: "itemPhoto")
        defaults.set(titleTextField.text, forKey: "title")
        defaults.set(descriptionTextField.text, forKey: "description")
        defaults.set(startingPriceTextField.text, forKey: "price")
        defaults.set(endDateTextField.text, forKey: "endDate")
        
        defaults.synchronize()*/
        
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
