//
//  AppDelegate.swift
//  RW - Paper
//
//  Created by Attila on 2014. 12. 01..
//  Copyright (c) 2014. -. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Set the window background color
        window?.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        
        // Configure app for full-screen presentation
        UIApplication.shared.isStatusBarHidden = false
        
        // Make sure we have a proper scene configuration
        if let window = self.window {
            // Ensure window fills the screen
            window.frame = UIScreen.main.bounds
            
            // Check if we already have a root view controller (from storyboard)
            if let rootVC = window.rootViewController {
                // Replace the standard root view controller with our custom one
                let fullScreenRootVC = FullScreenRootViewController(contentViewController: rootVC)
                window.rootViewController = fullScreenRootVC
            }
            
            window.makeKeyAndVisible()
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}
