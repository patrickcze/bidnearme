//
//  User.swift
//  Lulu
//
//  Created by Scott Campbell on 10/30/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class User {

    // MARK: - Properties
    var profileImage: UIImage!
    var firstName: String!
    var lastName: String!
    var rating: Int!
    
    var postedListings: [Listing]!
    var soldListings: [Listing]!
    var favoritedListings: [Listing]!
    var buyingListings: [Listing]!
    
    
    
    
    // User initialization.
    init(_ profileImage: UIImage, _ firstName: String, _ lastName: String) {
        self.profileImage = profileImage
        self.firstName = firstName
        self.lastName = lastName
    }
}


