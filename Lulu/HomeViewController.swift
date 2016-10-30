//
//  HomeViewController.swift
//  Lulu
//
//  Created by Scott Campbell on 10/30/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var listingsCollectionView: UICollectionView!
    
    // MARK: - Properties
    let reuseIdentifier = "ListingCollectionCell"
    
    // dummy listings to test UI, just temporary :)
    let tempData: [Listing] = [
        Listing([UIImage(named: "duck")!], "Duck for sale", "This is a duck i'm selling. Dope condition.", 10, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
        Listing([UIImage(named: "duck")!], "Selling a duck", "This is a duck i'm selling. Dope condition.", 12, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
        Listing([UIImage(named: "duck")!], "Duckss", "This is a duck i'm selling. Dope condition.", 13, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
        Listing([UIImage(named: "duck")!], "Duckling", "This is a duck i'm selling. Dope condition.", 8, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
        Listing([UIImage(named: "duck")!], "Ugly duckling", "This is a duck i'm selling. Dope condition.", 28, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
        Listing([UIImage(named: "duck")!], "Gray Goose", "This is a duck i'm selling. Dope condition.", 69, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
        Listing([UIImage(named: "duck")!], "Gander", "This is a duck i'm selling. Dope condition.", 100, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
        Listing([UIImage(named: "duck")!], "Talking Duck", "This is a duck i'm selling. Dope condition.", 11, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
        Listing([UIImage(named: "duck")!], "Duck is to good to pass up", "This is a duck i'm selling. Dope condition.", 6, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
        Listing([UIImage(named: "duck")!], "Duck Dodgers", "This is a duck i'm selling. Dope condition.", 10, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell"))]
    
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Notifies view controller that it's view laid out subviews.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Adjust listingsCollectionViewCell width to screensize.
        if let layout = listingsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let cellWidth = (view.bounds.width - 36.0) / 2.0
            let cellHeight = layout.itemSize.height
            layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
            layout.invalidateLayout()
        }
    }
}

// MARK: - UICollectionViewDataSource protocol
extension HomeViewController: UICollectionViewDataSource {
    
    // Required. Tell view how many cells to make.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tempData.count
    }
    
    // Required. Make a cell for each row in index path.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeCollectionViewCell
        cell.listing = tempData[indexPath.row]
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate protocol
extension HomeViewController: UICollectionViewDelegate {}
