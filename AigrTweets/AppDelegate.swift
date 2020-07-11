//
//  AppDelegate.swift
//  AigrTweets
//
//  Created by Adan Reséndiz on 14/06/20.
//  Copyright © 2020 Adan Reséndiz. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Create instance for Firebase
        FirebaseApp.configure()
        return true
    }


}

