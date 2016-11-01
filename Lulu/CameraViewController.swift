//
//  CameraViewController.swift
//  Lulu
//
//  Created by shreya on 2016-10-31.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
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
    
    //MARK properties
    
    //let tempUserData: User = User(UIImage(named: "duck")!, "Shreya", "Chopra")
    
    var user: User? {
        didSet {
            if let user = user {
                usersNameLabel.text = user.firstName + " " + user.lastName
                userImage.image = user.profileImage
                ratingLabel.text = String(user.rating) + " Stars"
                //yearLabel.text = "Member Since " + String(user.memberSince)
                //repliesInLabel.text = "Replies " + user.replyingHabit
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    /*func loadUserProfile() {
        

    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
