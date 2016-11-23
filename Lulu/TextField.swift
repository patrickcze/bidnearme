//
//  TextField.swift
//  Lulu
//
//  Created by Scott Campbell on 11/23/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class TextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
        
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
        
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
}
