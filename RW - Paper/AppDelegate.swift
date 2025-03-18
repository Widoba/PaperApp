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
        print("AppDelegate - application didFinishLaunchingWithOptions")
        
        // Create a fresh window with the correct size
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set the window background color
        window?.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        
        // Set up the root view controller from storyboard
        if setupRootViewController() {
            // Make the window visible
            window?.makeKeyAndVisible()
            print("AppDelegate - Window made key and visible")
        } else {
            print("AppDelegate - ERROR: Failed to set up root view controller")
        }
        
        return true
    }
    
    private func setupRootViewController() -> Bool {
        // Get the main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        print("AppDelegate - Loaded Main.storyboard")
        
        // Initialize the initial view controller from storyboard
        guard let initialVC = storyboard.instantiateInitialViewController() else {
            print("AppDelegate - ERROR: Failed to load initial view controller from storyboard")
            return false
        }
        
        print("AppDelegate - Loaded initial view controller: \(type(of: initialVC))")
        
        // Check if it's a navigation controller and ensure its view controllers are loaded
        if let navController = initialVC as? UINavigationController {
            print("AppDelegate - Initial view controller is a UINavigationController")
            
            // Make sure the navigation controller's views and child view controllers are loaded
            _ = navController.view
            
            // Print the navigation stack for debugging
            if let rootVC = navController.viewControllers.first {
                print("AppDelegate - Navigation controller's root view controller: \(type(of: rootVC))")
                _ = rootVC.view // Force view loading
            } else {
                print("AppDelegate - WARNING: Navigation controller has no view controllers")
            }
            
            // Create our container controller for the navigation controller
            let rootVC = FullScreenRootViewController(contentViewController: navController)
            
            // Set as the window's root view controller
            window?.rootViewController = rootVC
            print("AppDelegate - Set root view controller to FullScreenRootViewController containing NavController")
            return true
        } else {
            print("AppDelegate - Initial view controller is NOT a navigation controller")
            
            // Initialize if needed by accessing the view
            _ = initialVC.view
            
            // Create our container controller for the regular view controller
            let rootVC = FullScreenRootViewController(contentViewController: initialVC)
            
            // Set as the window's root view controller
            window?.rootViewController = rootVC
            print("AppDelegate - Set root view controller to FullScreenRootViewController")
            return true
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
