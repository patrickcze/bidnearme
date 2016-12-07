//
//  GroupTableViewCell.swift
//  Lulu
//
//  Created by Patrick Czeczko on 2016-12-03.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var groupTitle: UILabel!
    @IBOutlet weak var groupDesc: UILabel!
    @IBOutlet weak var groupItemCount: UILabel!
    @IBOutlet weak var groupMemberCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
