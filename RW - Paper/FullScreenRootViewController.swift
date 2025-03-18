//
//  FullScreenRootViewController.swift
//  RW - Paper
//
//  Created for fixing full-screen display issues
//

import UIKit

class FullScreenRootViewController: UIViewController {
    
    // The view controller we're wrapping
    private var contentViewController: UIViewController?
    
    // Background color for the app
    let backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
    
    convenience init(contentViewController: UIViewController) {
        self.init()
        self.contentViewController = contentViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background color
        view.backgroundColor = backgroundColor
        
        // Add the content view controller
        if let contentVC = contentViewController {
            addChild(contentVC)
            view.addSubview(contentVC.view)
            contentVC.didMove(toParent: self)
            
            // Ensure content view fills the entire screen
            contentVC.view.frame = view.bounds
            contentVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Force the content view to fill our bounds completely
        contentViewController?.view.frame = view.bounds
    }
    
    // Force status bar settings
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Disable safe area insets
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        if #available(iOS 11.0, *) {
            // Set additional insets to zero to counter any system-added insets
            additionalSafeAreaInsets = UIEdgeInsets(
                top: -view.safeAreaInsets.top,
                left: -view.safeAreaInsets.left,
                bottom: -view.safeAreaInsets.bottom,
                right: -view.safeAreaInsets.right
            )
        }
    }
    
    // Forward all unhandled messages to the content view controller
    override func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        }
        
        return contentViewController?.responds(to: aSelector) ?? false
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if super.responds(to: aSelector) {
            return self
        }
        
        return contentViewController
    }
    
    // Handle navigation controller delegation properly
    override var childForStatusBarStyle: UIViewController? {
        return contentViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return contentViewController
    }
    
    // Allow rotation to propagate to content view controller
    override var shouldAutorotate: Bool {
        return contentViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return contentViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return contentViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
    }
    
    // Make sure we don't break the navigation
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        // If we have a content view controller that's a navigation controller, let it handle the presentation
        if contentViewController is UINavigationController {
            contentViewController?.present(viewControllerToPresent, animated: flag, completion: completion)
        } else {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
} 