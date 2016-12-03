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
                if (list.winningBidId.isEmpty) {
                    setViewObjectDetails(imageUrl: list.imageUrls[0], title: list.title, highestBidAmount: list.startPrice)
                } else {
                    getListingBidById(listingId:list.listingId, bidId: list.winningBidId) { (bidObject) in
                        if let amount = bidObject?.amount {
                            self.setViewObjectDetails(imageUrl: list.imageUrls[0], title: list.title, highestBidAmount: amount)
                        }
                    }
                }
            }
        }
    }
    
    func setViewObjectDetails(imageUrl: URL, title: String, highestBidAmount: Double) {
        self.listingImageView.af_setImage(withURL: imageUrl)
        self.listingTitleLabel.text = title
        self.listingPriceTag.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.listingPriceLabel.text = "$" + String(format:"%.2f", highestBidAmount)
    }
}
