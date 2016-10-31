//
//  ProfileViewController.swift
//  Lulu
//
//  Created by Ronny on 2016-10-30.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tempUser = User(UIImage(named: "duck")!, "Scott", "Campbell")
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var mainTable: UITableView!
    
    var mainTableCells = ["Buying", "Selling"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTable.delegate = self
        mainTable.dataSource = self
        
        profilePicture?.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture?.clipsToBounds = true
        
        profilePicture.image = tempUser.profileImage
        tempUser.buyingListings = [
            Listing([UIImage(named: "duck")!], "Duck for sale", "This is a duck i'm selling. Dope condition.", 10, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
            Listing([UIImage(named: "duck")!], "Selling a duck", "This is a duck i'm selling. Dope condition.", 12, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
        ]
        
        // Do any additional setup after loading the view.
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mainTableCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableCell", for: indexPath) as! MainTableViewCell
        
        cell.tempUser = tempUser // temp
        
        // Configure the cell...
        let tableCell = mainTableCells[(indexPath as NSIndexPath).row]
        cell.nameLabel.text = tableCell
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate Method
/*    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
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
