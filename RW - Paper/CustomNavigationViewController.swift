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
