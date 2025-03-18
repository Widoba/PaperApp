//
//  CustomNavigationViewController.swift
//  RW - Paper
//
//  Created by Attila on 2014. 12. 07..
//  Copyright (c) 2014. -. All rights reserved.
//

import UIKit

class CustomNavigationViewController: UINavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        // Set up navigation controller for full screen display
        configureForFullScreen()
    }
    
    private func configureForFullScreen() {
        // Disable automatic adjustments
        navigationBar.isTranslucent = false
        
        // Set full screen appearance
        setNavigationBarHidden(true, animated: false)
        
        // Ensure background color matches app's background
        view.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        
        // Print current frame
        print("CustomNavigationViewController - Initial frame: \(view.frame)")
        print("CustomNavigationViewController - Screen bounds: \(UIScreen.main.bounds)")
        
        // Force the view to use full screen bounds
        view.frame = UIScreen.main.bounds
        print("CustomNavigationViewController - After setting frame: \(view.frame)")
        
        // Make sure our view doesn't automatically adjust for safe areas
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = UIEdgeInsets.zero
            view.insetsLayoutMarginsFromSafeArea = false
            
            // Make sure our child view controllers don't adjust their content for the safe area
            for childVC in children {
                childVC.additionalSafeAreaInsets = UIEdgeInsets.zero
                
                // Check for collection view controllers
                if let collectionVC = childVC as? UICollectionViewController {
                    collectionVC.collectionView?.contentInsetAdjustmentBehavior = .never
                }
                
                print("CustomNavigationViewController - Configured child: \(type(of: childVC))")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Always hide the navigation bar
        setNavigationBarHidden(true, animated: false)
        
        // Force full screen
        view.frame = UIScreen.main.bounds
        print("CustomNavigationViewController - viewWillAppear frame: \(view.frame)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Force frame to use full screen bounds
        view.frame = UIScreen.main.bounds
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            if let vc = fromVC as? BooksViewController {
                return vc.animationControllerForPresentController(vc: toVC)
            }
        }
        
        if operation == .pop {
            if let vc = toVC as? BooksViewController {
                return vc.animationControllerForDismissController(vc: vc)
            }
        }
        
        return nil
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let animationController = animationController as? BookOpeningTransition {
            return animationController.interactionController
        }
        return nil
    }
    
}
