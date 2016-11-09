//
//  TableViewController.swift
//  Lulu
//
//  Created by Ronny on 2016-11-08.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    //MARK: - Properties
    let cellIdentifier = "ProfileCell"
    var listings : [Listing]!
    var listingType = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.tableView.delegate = self
        self.tableView.dataSource = self
        listings = []
//        self.tableView.layer.borderWidth = 0.3
//        self.tableView.layer.borderColor = UIColor.black.cgColor
//        self.tableView.layer.cornerRadius = 0
//        
        // registering the tableViewCell I made, so it can be used
        let nib = UINib(nibName: "ProfileTableViewCell", bundle: nil)
        self.tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.tableView.register(nib,forCellReuseIdentifier: cellIdentifier)
        // WHAT ABOUT UNREGISTERING? 
        
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listings.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProfileTableViewCell
        
        let index = indexPath as NSIndexPath
        let listing = listings[index.row]
        
        cell.itemPhoto.image = UIImage(named: "eggs")
        cell.itemTitle.text = listing.title
        cell.bigLabel.text = "$ 15"
        
        switch listingType {
        case 0, 4:
            cell.smallLabel.text = " bidders"
        case 1,3:
            cell.smallLabel.text = " date"
        case 2:
            cell.smallLabel.text = " Highest bid"
        default:
            print("Default -> tableViewController -> cellForRowAt (Profile)")
        }
        return cell
    }
 
  
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}
