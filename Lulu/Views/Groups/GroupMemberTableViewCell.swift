//
//  GroupMemberTableViewCell.swift
//  Lulu
//
//  Created by Patrick Czeczko on 2016-12-06.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class GroupMemberTableViewCell: UITableViewCell {
    @IBOutlet weak var memberStateCheckBox: M13Checkbox!
    @IBOutlet weak var memberName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
