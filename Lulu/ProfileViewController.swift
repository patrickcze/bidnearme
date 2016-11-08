//
//  ProfileViewController.swift
//  Lulu
//
//  Created by Ronny on 2016-10-30.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    //MARK: - outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var specialLabel: UILabel!
    @IBOutlet weak var buySellFavorite_Segment: UISegmentedControl!
    
    // temp
    var tempUser : User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Making the imageView Circular
        profilePicture?.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture?.clipsToBounds = true
        
        // accessing data stored in the appDelegate
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let temp = appDelegate?.dummyUser
        {
            tempUser = temp
            profilePicture.image = tempUser.profileImage
            buySellFavorite_Segment.selectedSegmentIndex = 0
            buySellFavorite_Segment.sendActions(for: UIControlEvents.valueChanged)
            
        }
        else // handle this more properly with exceptions later
        {
            print("*** ProfileViewController: user NULL ***")
        }
    }
    
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        
        if (tempUser != nil)
        {
            let tableV = self.storyboard?.instantiateViewController(withIdentifier: "ProfileTableView") as! ProfileTableViewController
            
            containerView.addSubview(tableV.view)
            addChildViewController(tableV)
            tableV.didMove(toParentViewController: self)
            
            switch (sender.selectedSegmentIndex)
            {
            case 0: // Buy
                tableV.topTableLabel.text = "Buying"
                tableV.bottomTableLabel.text = "Bought"
                tableV.topListing = tempUser.buyingListings
                tableV.bottomListing = tempUser.buyingListings
                break
            case 1: // Sell
                tableV.topTableLabel.text = "Selling"
                tableV.bottomTableLabel.text = "Sold"
                tableV.topListing = tempUser.postedListings
                tableV.bottomListing = tempUser.soldListings
                break
            case 2: // Favorite
                tableV.topTableLabel.text = "Watching"
                tableV.topListing = tempUser.favoritedListings
                tableV.bottomListing = tempUser.postedListings
                tableV.bottomTableLabel.isHidden = true
                tableV.bottomTableView.isHidden = true
                break
            default:
                print("Default - segmentValueChanged - Profile.storyboard")
            }
            tableV.view.frame = containerView.bounds
            tableV.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    
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
