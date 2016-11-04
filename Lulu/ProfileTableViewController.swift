//
//  ProfileTableViewController.swift
//  Lulu
//
//  Created by Ronny on 2016-11-02.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class ProfileTableViewController: UIViewController {
    
    var buttonPressedLESS = false
    var buttonPressedMORE = false
    
    var topRows = 3
    var bottomRows = 3
    
    @IBOutlet weak var topTableLabel: UILabel!
    @IBOutlet weak var bottomTableLabel: UILabel!
    
    @IBOutlet weak var topTableView: UITableView!
    @IBOutlet weak var bottomTableView: UITableView!
  
    @IBOutlet weak var topTableViewButton: UIButton!
    @IBOutlet weak var bottomTableViewButton: UIButton!
    
    
    var topListing : [Listing]!
    var bottomListing : [Listing]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        buttonPressedMORE = false
        buttonPressedLESS = false
        topRows = 3
        bottomRows = 3
        
        // registering the dtableViewCell I made so it can be used
        let nib = UINib(nibName: "ProfileTableViewCell", bundle: nil)
        
        topTableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: "ProfileCell")
        topTableView.register(nib,forCellReuseIdentifier: "ProfileCell")
        
        bottomTableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: "ProfileCell")
        bottomTableView.register(nib, forCellReuseIdentifier: "ProfileCell")
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func tableViewButtonPressed(_ sender: UIButton) {
        
        if (sender.titleLabel != nil)
        {
            let name = String(describing: (sender.titleLabel?.text)!)
            
            switch (name)
            {
            case "Show More":
                if (sender.tag == 0) // top
                {
                    buttonPressedMORE = true
                    topTableView.reloadData()
                }
                else if (sender.tag == 1) // bottom
                {
                    buttonPressedMORE = true
                    bottomTableView.reloadData()
                }
            
                break
            case "Show Less":

                if (sender.tag == 0) // top
                {
                    buttonPressedLESS = true
                    topTableView.reloadData()
                }
                else if (sender.tag == 1) // bottom
                {
                    buttonPressedLESS = true
                    bottomTableView.reloadData()
                }
            
                break
            default:
                print("Default ProfileTableViewController - button pressed - TAG:  \(sender.tag)  -- NAME: \(sender.titleLabel?.text)")
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




// MARK: - UITableViewDataSource protocol
extension ProfileTableViewController: UITableViewDataSource {
    
       override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
       return 1
    }
    
    
    // default number of rows in a table is 3 rows. If tableViewListing is less thatn oe equal to 3,
    // then no "Show More/button" will show up. Otherwiswe a button will show up.
    //
    //      When user clicks on Show More, totalRows = list.count and button title gets changed
    //      When User clicks on Show less, totalRows = 3 and button title gets changed
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (tableView.tag)
        {
        case 0: // top table view

            if (topListing != nil)
            {

                if (buttonPressedMORE) // change button title to Show Less
                {
                    topRows = topListing.count
                    topTableViewButton.setTitle("Show Less", for: .normal)
                    topTableViewButton.isHidden = false
                    buttonPressedMORE = false
                    
                }
                else if (buttonPressedLESS)
                {
                    topRows = 3
                    topTableViewButton.setTitle("Show More", for: .normal)
                    topTableViewButton.isHidden = false
                    buttonPressedLESS = false
                    
                }
                else if (topListing.count <= topRows)
                {
                    topTableViewButton.isHidden = true
                    topRows = topListing.count
                }
                else if (topListing.count > topRows)
                {
                    topTableViewButton.setTitle("Show More", for: .normal)
                    topTableViewButton.isHidden = false
                }
            }
            
            return topRows
    
            
        case 1: // bottom table view
            
            if (bottomListing != nil)
            {
                if (buttonPressedMORE) // change button title to Show Less
                {
                    bottomRows = bottomListing.count
                    bottomTableViewButton.setTitle("Show Less", for: .normal)
                    bottomTableViewButton.isHidden = false
                    buttonPressedMORE = false
                    
                }
                else if (buttonPressedLESS) // change button title to Show More
                {
                    bottomRows = 3
                    bottomTableViewButton.setTitle("Show More", for: .normal)
                    bottomTableViewButton.isHidden = false
                    buttonPressedLESS = false
                    
                }
                else if (bottomListing.count <= bottomRows)
                {
                    bottomTableViewButton.isHidden = true
                    bottomRows = bottomListing.count
                }
                else if (bottomListing.count > bottomRows)
                {
                    bottomTableViewButton.setTitle("Show More", for: .normal)
                    bottomTableViewButton.isHidden = false
                }
            }
            
            return bottomRows
        
        default:
                print("Profiletableview #ofSections - default - TableView Tag \(tableView.tag)")
                return 0
        }
    }
    
    
    // Sets up the cell according to what tableView is. There are 2 tables views: Top and Bottom
    // 0 -> Top tableView
    //      If topTableView, it will use topListing
    // 1 -> Bottom tableView
    //      if bottomTableView, it will use bottomListing
    //
    // "ProfileViewController" set the lists above (ex. user favoritesListings, buyingListings, etc.)
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileTableViewCell
        
        switch(tableView.tag)
        {
            
        case 0:
            print("Top Table")
            
            let index = indexPath as NSIndexPath
            if (topListing != nil && indexPath.row <= topListing.count)
            {
                let l = topListing[index.row]
                cell.itemPhoto.image = l.photos.first
                cell.itemTitle.text = l.title
                cell.bigLabel.text = String(l.buyoutPrice)
            }
            
            return cell
            
        case 1:
            print("Bottom Table")

            let index = indexPath as NSIndexPath
            if (bottomListing != nil && indexPath.row <= bottomListing.count)
            {
                let l = bottomListing[index.row]
                cell.itemPhoto.image = l.photos.first
                cell.itemTitle.text = l.title
                cell.bigLabel.text = String(l.buyoutPrice)
            }
            
            return cell
        default:
            print("ProfileTableView cellForRowAt - Default - TableView Tag: \(tableView.tag) ")
            return ProfileTableViewCell.init(style: .default, reuseIdentifier: "ProfileCell")
        }
    }
}

// MARK: - UITableViewDelegate protocol
extension ProfileTableViewController: UITableViewDelegate { }

