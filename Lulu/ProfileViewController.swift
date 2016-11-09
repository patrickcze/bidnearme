//
//  ProfileViewController.swift
//  Lulu
//
//  Created by Ronny on 2016-10-30.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var arrowLabel: UILabel!
    @IBOutlet weak var doubleArrowIcon: UIImageView!
    //MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var specialLabel: UILabel!
    @IBOutlet weak var listingPickerView: UIPickerView!
    @IBOutlet weak var listingSelectionButton: UIButton!
   
    //MARK: - Properties
    let pickerViewTitles = ["Buying", "Bought", "Selling", "Sold", "Favorites"]
    var allListings : [[Listing]]!
    // temp
    var tempUser : User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
 
        listingPickerView.delegate = self
        listingPickerView.dataSource = self
        listingPickerView.isHidden = true
        
        // Making the imageView Circular
        profilePicture?.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture?.clipsToBounds = true
        
        // accessing data stored in the appDelegate
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let temp = appDelegate?.dummyUser {
            tempUser = temp
            profilePicture.image = tempUser.profileImage
            
            allListings = [
                tempUser.buyingListings,   // 0
                tempUser.buyingListings,   // 1 <- THIS should be boughtListings
                tempUser.postedListings,   // 2
                tempUser.soldListings,     // 3
                tempUser.favoritedListings // 4
            ]
            
            
            listingSelectionButton.setTitle(String(pickerViewTitles[2]), for: .normal)
            listingPickerView.selectRow(2, inComponent: 0, animated: false)
            self.pickerView(listingPickerView, didSelectRow: 2, inComponent: 0)
            
            
        }
        else { // handle this more properly with exceptions later
            print("*** ProfileViewController: user NULL ***")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func listingSelectionPressed(_ sender: UIButton) {
        listingPickerView.isHidden = false
        listingSelectionButton.isHidden = true
        doubleArrowIcon.isHidden = true
        listingPickerView.becomeFirstResponder()
    }
    
    // TODO: Make sure about this if it works when you click on the tableviewCell when
    // pickerView was visible (it was not working)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        listingPickerView.resignFirstResponder()
        listingPickerView.isHidden = true
        listingSelectionButton.isHidden = false
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


// MARK: - UIPickerDataSource protocol
extension ProfileViewController: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewTitles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // there is only one component
        if (component == 0 && tempUser != nil) {
            
            let tableView = self.storyboard?.instantiateViewController(withIdentifier: "TableViewController") as! TableViewController
            
            containerView.addSubview(tableView.view)
            addChildViewController(tableView)
            tableView.didMove(toParentViewController: self)
            
            tableView.listings = allListings[row]
            tableView.listingType = row
            
            listingSelectionButton.setTitle(String(pickerViewTitles[row]), for: .normal)
            
            switch(row) {
            // Buying
            case 0:
                break;
            // Bought
            case 1:
                break
            // Selling
            case 2:
                break
            // Sold
            case 3:
                break
            // Favorites
            case 4:
                break
            default:
                print("Default -> ProfileViewController -> didSelectRow PickerView")
            }
            
            tableView.view.frame = containerView.bounds
            tableView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            listingPickerView.isHidden = true
            listingSelectionButton.isHidden = false
            doubleArrowIcon.isHidden = false
        }
    }
    
    //    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    //        <#code#>
    //    }
    //
    //    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
    //        <#code#>
    //    }
    //
    //   func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    //
    //        return CGFloat(10)
    //
    //  }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    
}

// MARK: - UIPickerDataSource protocol
extension ProfileViewController: UIPickerViewDelegate {
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewTitles.count
    }
    
}


