//
//  TextField.swift
//  Lulu
//
//  Created by Scott Campbell on 11/23/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

// Subclass for custom textField insets.
class TextField: UITextField {
    
    // Returns the drawing rectangle for the text field’s text.
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
    
    // Returns the drawing rectangle for the text field’s placeholder text.
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
    
    // Returns the rectangle in which editable text can be displayed.
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
}
