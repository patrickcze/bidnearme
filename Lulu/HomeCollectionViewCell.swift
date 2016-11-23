//
//  HomeCollectionViewCell.swift
//  Lulu
//
//  Created by Scott Campbell on 10/30/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var listingImageView: UIImageView!
    @IBOutlet weak var listingTitleLabel: UILabel!
    @IBOutlet weak var listingPriceTag: UIView!
    @IBOutlet weak var listingPriceLabel: UILabel!
    
    // MARK: - Properties
    var listing: Listing? {
        didSet {
            if let list = listing {
                listingImageView.af_setImage(withURL: list.photos[0])
                listingTitleLabel.text = list.title
                listingPriceTag.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                listingPriceLabel.text = "$" + String(format:"%.2f", list.startPrice)
            }
        }
    }
}
