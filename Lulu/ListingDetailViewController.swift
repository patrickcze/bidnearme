//
//  ListingDetailViewController.swift
//  Lulu
//
//  Created by Scott Campbell on 11/21/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import MapKit
import FirebaseStorage
import FirebaseDatabase
import Alamofire
import AlamofireImage

class ListingDetailViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var listingImageView: UIImageView!
    @IBOutlet weak var listingTitleLabel: UILabel!
    @IBOutlet weak var listingDescriptionLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileRating: RatingControl!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeBidButton: UIButton!
    
    // MARK: - Properties
    var listing: Listing?
    var textField: UITextField!
    var toolbarTextField: UITextField!
    
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.keyboardType = .numberPad
        textField.delegate = self
        view.addSubview(textField)
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        placeBidButton.backgroundColor = UIColor(red: 0.0, green: 0.35, blue: 0.71, alpha: 1)
        
        mapView.layer.cornerRadius = 5.0
        setGeocoder()
        
        if let listing = listing {
            listingImageView.af_setImage(withURL: listing.photos[0])
            listingTitleLabel.text = listing.title
            listingDescriptionLabel.text = listing.description
            
            profileImageView.image = listing.seller.profileImage
            profileNameLabel.text = "\(listing.seller.firstName!) \(listing.seller.lastName!)"
            
            // TODO: Implement ratings for sellers.
            profileRating.rating = 3
            
            for button in profileRating.ratingButtons{
                button.isUserInteractionEnabled = false
            }
        }
    }
    
    // MARK: - MKMapView
    
    // Set a new geocoder for annotating the lister's location on the mapView.
    func setGeocoder() {
        // MapKit Geo Coder
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString("34 Bridlecreek Pk Sw, Calgary AB, Canada T2Y3N6", completionHandler: { placemarks, error in
            if error != nil {
                print(error!)
                return
            }
            
            // Get the placemarks. Always take first mark.
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                
                if let location = placemark.location {
                    self.setLocationOverlay(location.coordinate)
                    
                    // Set the zoom level.
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
                    self.mapView.setRegion(region, animated: false)
                }
            }
        })
    }
    
    // Create a circular map overlay for seller's location.
    func setLocationOverlay(_ center: CLLocationCoordinate2D) {
        let radius = CLLocationDistance(150)
        let overlay = MKCircle(center: center, radius: radius)
        
        mapView.add(overlay)
    }
    
    // MARK: - Actions
    
    // Respond to placeBid tap.
    func tappedBid() {
        view.endEditing(true)
        textField.resignFirstResponder()
    }
    
    // Respond to tappedBidButton tap.
    @IBAction func tappedBidButton(_ sender: Any) {
        textField.becomeFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension ListingDetailViewController: UITextFieldDelegate {
    
    // Optional. Asks the delegate if editing should begin in the specified text field.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.barStyle = UIBarStyle.default
        
        toolbarTextField = TextField()
        toolbarTextField.keyboardType = .numberPad
        toolbarTextField.backgroundColor = UIColor.lightText
        toolbarTextField.layer.cornerRadius = 5.0
        toolbarTextField.placeholder = "Enter your price"
        toolbarTextField.sizeToFit()
        
        keyboardToolbar.setItems([
            UIBarButtonItem(customView: toolbarTextField),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Place Bid", style: .plain, target: self, action: #selector(tappedBid))
            ], animated: false)
        
        keyboardToolbar.isUserInteractionEnabled = true
        keyboardToolbar.sizeToFit()
        textField.inputAccessoryView = keyboardToolbar
        
        toolbarTextField.becomeFirstResponder()
        
        return true
    }
    
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    //
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // TODO: deal with this in some way
    }
    
    //
    func textFieldDidEndEditing(_ textField: UITextField) {
        // TODO: deal with this in some way
    }
}

// MARK: - MKMapViewDelegate protocol
extension ListingDetailViewController: MKMapViewDelegate {
    
    // Optional. Asks the delegate for a renderer object to use when drawing the specified overlay.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor(red: 0.0, green: 0.35, blue: 0.71, alpha: 1).withAlphaComponent(0.5)
        circleRenderer.strokeColor = UIColor(red: 0.0, green: 0.35, blue: 0.71, alpha: 1)
        circleRenderer.lineWidth = 1.0
        
        return circleRenderer
    }
}
