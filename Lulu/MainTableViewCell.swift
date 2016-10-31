//
//  MainTableViewCell.swift
//  Lulu
//
//  Created by Martin on 2016-10-31.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell,  UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var subTableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var tempUser: User!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        subTableView.delegate = self
        subTableView.dataSource = self
        
          // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2 //(tempUser?.buyingListings.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubTableCell", for: indexPath) as! SubTableViewCell
        
        // Configure the cell...
      //  let tableCell = tempUser.buyingListings[(indexPath as NSIndexPath).row]
        
        cell.itemImage.image = UIImage(named: "duck")//tableCell.photos.first
        cell.itemTitleLabel.text = "Tv"//tableCell.title
        cell.itemPriceLabel.text = "%15.99"//String(tableCell.buyoutPrice)
        cell.itemMiniLabel.text = "16"//String(tableCell.bidders.count)
        return cell
    }
    

}
