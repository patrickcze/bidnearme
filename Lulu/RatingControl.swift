//
//  RatingControl.swift
//  Lulu
//
//  Created by Scott Campbell on 11/21/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class RatingControl: UIView {
    
    // MARK: - Properties
    var rating = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var reviews = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var ratingButtons = [UIButton]()
    var reviewLabel = UILabel()
    let buttonSpacing = 2
    let labelSpacing = 3
    let starCount = 5
    
    // MARK: - Initialization
    
    // Failable initializer.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let filledStar = UIImage(named: "star-filled")
        let emptyStar = UIImage(named: "star-empty")
        
        for _ in 0..<starCount {
            let button = UIButton()
            
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            
            button.adjustsImageWhenDisabled = false
            
            ratingButtons += [button]
            addSubview(button)
        }
        
        reviewLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        reviewLabel.textColor = UIColor.lightGray
        reviewLabel.text = String(self.reviews) + " Reviews"
        
        addSubview(reviewLabel)
    }
    
    // The natural size for the receiving view, considering only properties of the view itself.
    override public var intrinsicContentSize: CGSize {
        let buttonSize = Int(frame.size.height / 1.25)
        let width = (buttonSize * starCount) + (buttonSpacing * (starCount - 1)) + Int(reviewLabel.frame.width)
        
        return CGSize(width: width, height: buttonSize)
    }
    
    // Lays out subviews.
    override func layoutSubviews() {
        let buttonSize = Int(frame.size.height / 1.25)
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        // Offset each buttons' origin by the length of the button plus spacing.
        for (index, button) in ratingButtons.enumerated() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + buttonSpacing))
            button.frame = buttonFrame
        }
        
        // Offset the labels' origin
        var labelFrame = CGRect(x: 0, y: 0, width: buttonSize * 10, height: buttonSize)
        labelFrame.origin.x = CGFloat(5 * (buttonSize + labelSpacing))
        
        reviewLabel.frame = labelFrame
        
        updateButtonSelectionStates()
        updateReviewCount()
    }
    
    // If the index of a button is less than the rating, that button should be selected.
    func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
    
    // Update the number of reviews.
    func updateReviewCount() {
        reviewLabel.text = String(self.reviews) + " Reviews"
    }
}

