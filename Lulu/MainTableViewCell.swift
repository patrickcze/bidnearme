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
    
    @IBOutlet var showMoreButton: UIButton!
    
    var tableTotalRows = 3
    
    var tempUser: User!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        subTableView.delegate = self
        subTableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let temp = appDelegate?.dummyUser
        {
            tempUser = temp
        }
        else
        {
            print("MainTableViewCell: user null")
        }
        
          // Initialization code
    }

//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        
//        let index = indexPath
//        
//        if( index == )
//
//

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // returning the number of rows
        if tableTotalRows > tempUser.buyingListings.count {
            tableTotalRows = tempUser.buyingListings.count
        }
        return tableTotalRows//tempUser.buyingListings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubTableCell", for: indexPath) as! SubTableViewCell
        
        // Configuring the cell...
       
        let tableCell = tempUser.buyingListings[(indexPath as NSIndexPath).row]
       
        cell.itemImage.image = tableCell.photos.first
        cell.itemTitleLabel.text = tableCell.title
        cell.itemPriceLabel.text = "$" + String(tableCell.buyoutPrice)
        cell.itemMiniLabel.text = "16"//String(tableCell.bidders.count)
       
        return cell
    
    }
    
    @IBAction func showMorePressed(_ sender: UIButton) {
  
        if showMoreButton.currentTitle != "Show Less"
        {
            tableTotalRows = tableTotalRows * Int(ceil(Double(tempUser.buyingListings.count) / 3.0))
            showMoreButton.setTitle("Show Less", for: .normal)
        }
        else
        {
            tableTotalRows = 3
            showMoreButton.setTitle("Show More", for: .normal)
        }
        
        
        self.subTableView.reloadData()
        
    }
    
}
