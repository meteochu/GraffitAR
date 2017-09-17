//
//  AppDelegate.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        CAMetalLayer.setupSwizzling()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // deep linking with facebook sdk
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }

}

