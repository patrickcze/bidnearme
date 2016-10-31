//
//  SubTableViewCell.swift
//  Lulu
//
//  Created by Martin on 2016-10-31.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class SubTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var itemTitleLabel: UILabel!

    @IBOutlet weak var itemPriceLabel: UILabel!
    
    @IBOutlet weak var itemMiniLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
