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
        
        // Configure full-screen presentation
        // Note: Status bar appearance is now controlled via view controllers, not globally
        // The deprecated call has been removed
        
        // Make sure we have a proper scene configuration
        if let window = self.window {
            // Ensure window fills the screen
            window.frame = UIScreen.main.bounds
            print("AppDelegate - Window size: \(window.frame.size)")
            
            // Handle our custom root view controller setup
            setupRootViewControllerDirectly(for: window)
            
            window.makeKeyAndVisible()
            
            // Print final window configuration
            print("AppDelegate - Final window config - root: \(type(of: window.rootViewController))")
        }
        
        return true
    }
    
    private func setupRootViewControllerDirectly(for window: UIWindow) {
        // Get the storyboard (use Main.storyboard)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Get the initial view controller from the storyboard
        if let initialVC = storyboard.instantiateInitialViewController() {
            print("AppDelegate - Created initial view controller: \(type(of: initialVC))")
            
            // Force view to load
            _ = initialVC.view
            
            // Create our custom container
            let fullScreenRootVC = FullScreenRootViewController(contentViewController: initialVC)
            
            // Force view to load
            _ = fullScreenRootVC.view
            
            // Set as root
            window.rootViewController = fullScreenRootVC
            
            print("AppDelegate - Set root to FullScreenRootViewController containing \(type(of: initialVC))")
        } else {
            print("AppDelegate - ERROR: Could not instantiate initial view controller from storyboard")
        }
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
