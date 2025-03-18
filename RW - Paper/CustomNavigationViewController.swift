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
        
        // Force the view to use full screen bounds
        view.frame = UIScreen.main.bounds
        
        // Ensure we don't respect safe area insets
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = UIEdgeInsets.zero
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Always hide the navigation bar
        setNavigationBarHidden(true, animated: false)
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
