//
//  ProfileTableViewCell.swift
//  Lulu
//
//  Created by Ronny on 2016-11-02.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var bigLabel: UILabel!
    @IBOutlet weak var itemPhoto: UIImageView!
    @IBOutlet weak var smallLabel: UILabel!
    
   override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
