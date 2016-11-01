//
//  ProfileViewController.swift
//  Lulu
//
//  Created by Ronny on 2016-10-30.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tempUser : User!
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var mainTable: UITableView!
    
    let MainCellHeight : CGFloat = 212


    var mainTableCells = ["Buying", "Selling"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTable.delegate = self
        mainTable.dataSource = self
      //  mainTable.estimatedRowHeight = MainCellHeight
      //  mainTable.rowHeight = MainCellHeight//UITableViewAutomaticDimension
         print(mainTable.estimatedRowHeight)
        print(mainTable.rowHeight)
        
        profilePicture?.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture?.clipsToBounds = true

        
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let temp = appDelegate?.dummyUser
        {
            tempUser = temp
            profilePicture.image = tempUser.profileImage
        }
        else
        {
            print("ProfileViewController: user null")
        }

        
        
        
        
        // Do any additional setup after loading the view.
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return mainTableCells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
     
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableCell", for: indexPath) as! MainTableViewCell
        
        //cell.showMoreButton.tag = (indexPath as NSIndexPath).row
        // Configure the cell...
        let index = indexPath as NSIndexPath
        
        print("section- " +  String(index.section) + "      row - " + String(index.row))
        
        if index.section == 0
        {
            let tableCell = mainTableCells[0]
            cell.nameLabel.text = tableCell
        }
        else if index.section == 1
        {
            let tableCell = mainTableCells[1]
            cell.nameLabel.text = tableCell

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        print("mainTableRowHeight set at 225  -> (ProfileViewController)")
        return 225
        
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
