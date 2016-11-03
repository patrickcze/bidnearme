//
//  ProfileViewController.swift
//  Lulu
//
//  Created by Ronny on 2016-10-30.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    var tempUser : User!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
 
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var memberLabel: UILabel!
    
    @IBOutlet weak var specialLabel: UILabel!
    
    @IBOutlet weak var buySellFavorite_Segment: UISegmentedControl!
    
    var currentTabItem = 0
    let mainTableCellNames = [["Buying", "Bought"],["Selling","Sold"],["Favorites"]]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        
        
        
       // buySellFavorite_Segment.didChangeValue(forKey: "Buy")
        profilePicture?.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture?.clipsToBounds = true

        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let temp = appDelegate?.dummyUser
        {
            tempUser = temp
            profilePicture.image = tempUser.profileImage
            buySellFavorite_Segment.selectedSegmentIndex = 0
            buySellFavorite_Segment.sendActions(for: UIControlEvents.valueChanged)
            
        }
        else
        {
            print("ProfileViewController: user null")
        }
        
    
        // Do any additional setup after loading the view.
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
      
        print("segment control Value Changed")
        print(" TAG = " + String(sender.tag))
        
        switch (sender.selectedSegmentIndex)
        {
        case 0: // Buy
            
            print("setting up viewController for BUY segemntControl")
            
            let tableV = self.storyboard?.instantiateViewController(withIdentifier: "ProfileTableView") as! ProfileTableViewController
            
            containerView.addSubview(tableV.view)
            addChildViewController(tableV)
            tableV.didMove(toParentViewController: self)
            
            tableV.bottomTableLabel.text = "Bought"
            tableV.topTableLabel.text = "Buying"
            
            tableV.topListing = tempUser.buyingListings
            tableV.bottomListing = tempUser.buyingListings
            
            tableV.view.frame = containerView.bounds
            tableV.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            
            
            break
        case 1: // Sell
            print("setting up viewController for SELL segemntControl")
            
            let tableV = self.storyboard?.instantiateViewController(withIdentifier: "ProfileTableView") as! ProfileTableViewController
            
            containerView.addSubview(tableV.view)
            addChildViewController(tableV)
            tableV.didMove(toParentViewController: self)
            
            tableV.bottomTableLabel.text = "Selling"
            tableV.topTableLabel.text = "Sold"
            
            tableV.topListing = tempUser.postedListings
            tableV.bottomListing = tempUser.postedListings
            
            tableV.view.frame = containerView.bounds
            tableV.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            break
        case 2: // Favorite
            print("setting up viewController for FAVORITE segemntControl")
            
            let tableV = self.storyboard?.instantiateViewController(withIdentifier: "ProfileTableView") as! ProfileTableViewController
            
            containerView.addSubview(tableV.view)
            addChildViewController(tableV)
            tableV.didMove(toParentViewController: self)
            
            tableV.topTableLabel.text = "Watching"
            
            tableV.topListing = tempUser.favoritedListings
            tableV.bottomListing = tempUser.postedListings
            
            
            tableV.bottomTableLabel.isHidden = true
            tableV.bottomTableView.isHidden = true
            
            
            tableV.view.frame = containerView.bounds
            tableV.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            break
        default:
            print("Default - segmentValueChanged - Profile.storyboard")
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
