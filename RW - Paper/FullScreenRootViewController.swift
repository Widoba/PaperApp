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
    
    // Add a proper initializer
    init(contentViewController: UIViewController) {
        self.contentViewController = contentViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("FullScreenRootViewController - viewDidLoad")
        print("FullScreenRootViewController - Screen bounds: \(UIScreen.main.bounds)")
        print("FullScreenRootViewController - Initial view frame: \(view.frame)")
        
        // Make sure we're using the full screen size
        view.frame = UIScreen.main.bounds
        
        // Set the background color to be clearly visible
        view.backgroundColor = UIColor.purple
        
        // Add the content view controller
        if let contentVC = contentViewController {
            print("FullScreenRootViewController - Adding content view controller: \(type(of: contentVC))")
            
            // Basic containment pattern
            addChild(contentVC)
            view.addSubview(contentVC.view)
            
            // Use frame-based approach to fill the full screen
            contentVC.view.frame = UIScreen.main.bounds
            contentVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            print("FullScreenRootViewController - Content view frame after setup: \(contentVC.view.frame)")
            
            contentVC.didMove(toParent: self)
            
            // Force a layout update
            view.setNeedsLayout()
            view.layoutIfNeeded()
            
            print("FullScreenRootViewController - After layout, content view frame: \(contentVC.view.frame)")
        } else {
            print("FullScreenRootViewController - ERROR: No content view controller provided!")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("FullScreenRootViewController - viewWillAppear, view frame: \(view.frame)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("FullScreenRootViewController - viewDidAppear, view frame: \(view.frame)")
        print("FullScreenRootViewController - Content view frame: \(contentViewController?.view.frame ?? .zero)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Make sure our view fills the entire screen
        if let window = view.window {
            view.frame = window.bounds
        }
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
        
        // Only proceed if view is loaded and in window hierarchy
        guard isViewLoaded && view.window != nil else { return }
        
        if #available(iOS 11.0, *) {
            // Check if safe area insets are valid before trying to counter them
            let insets = view.safeAreaInsets
            if insets != .zero {
                // Set additional insets to zero to counter any system-added insets
                additionalSafeAreaInsets = UIEdgeInsets(
                    top: -insets.top,
                    left: -insets.left,
                    bottom: -insets.bottom,
                    right: -insets.right
                )
            }
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