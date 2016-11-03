//
//  AppDelegate.swift
//  Lulu
//
//  Created by Jan Clarin on 10/17/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // ronny - TEMPORAL
    var dummyUser : User!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // ronny - TEMPORAL
        dummyUser = User(UIImage(named: "duck")!, "Mr. Duck", "Duckin")
        
        dummyUser.buyingListings = [
                Listing([UIImage(named: "duck")!], "Duck for sale", "This is a duck i'm selling. Dope condition.", 10, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
                Listing([UIImage(named: "duckShoes")!], "Selling duck shoes", "These shoes are for ducks. Dope condition.", 12, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
                Listing([UIImage(named: "duck")!], "Selling a duck", "This is a duck i'm selling. Dope     condition.", 12, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
                Listing([UIImage(named: "duck")!], "Selling a duck", "This is a duck i'm selling. Dope condition.", 12, 25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell")),
                Listing([UIImage(named: "duck")!], "Duckss", "This is a duck i'm selling. Dope condition.", 13,    25, "Oct 30", "Nov 9", User(UIImage(named: "duck")!, "Scott", "Campbell"))
                                    ]
        
        dummyUser.postedListings = [
                                    Listing([UIImage(named: "eggs")!], "Duck eggs for sale!", "I stole my friends eggs so I am taking advantage and selling them for cheap!", 10, 25, "Oct 30", "Nov 9", User(UIImage(named: "eggs")!, "Scott", "Campbell")),
                                    Listing([UIImage(named: "eggs")!], "Duck eggs for sale!", "I stole my friends eggs so I am taking advantage and selling them for cheap!", 10, 25, "Oct 30", "Nov 9", User(UIImage(named: "eggs")!, "Scott", "Campbell")),
                                    Listing([UIImage(named: "eggs")!], "Duck eggs for sale!", "I stole my friends eggs so I am taking advantage and selling them for cheap!", 10, 25, "Oct 30", "Nov 9", User(UIImage(named: "eggs")!, "Scott", "Campbell")),
                                    Listing([UIImage(named: "eggs")!], "Duck eggs for sale!", "I stole my friends eggs so I am taking advantage and selling them for cheap!", 10, 25, "Oct 30", "Nov 9", User(UIImage(named: "eggs")!, "Scott", "Campbell"))
                                    ]
        dummyUser.favoritedListings = [
            Listing([UIImage(named: "duckCar")!], "Duck car for sale!", "I am selling this because I am getting too old", 10, 25, "Oct 30", "Nov 9", User(UIImage(named: "eggs")!, "Scott", "Campbell")),
            Listing([UIImage(named: "duckCar")!], "Duck car for sale!", "I am selling this because I am getting too old", 10, 25, "Oct 30", "Nov 9", User(UIImage(named: "eggs")!, "Scott", "Campbell"))
        ]
        
        dummyUser.allListings = [dummyUser.buyingListings,dummyUser.buyingListings,dummyUser.postedListings,dummyUser.postedListings, dummyUser.favoritedListings]
        
        // -----
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

