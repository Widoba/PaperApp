//
//  BookOpeningTransition.swift
//  RW - Paper
//
//  Created by Attila on 2014. 12. 07..
//  Copyright (c) 2014. -. All rights reserved.
//

import UIKit

class BookOpeningTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPush = true
    var interactionController: UIPercentDrivenInteractiveTransition?
    var toViewBackgroundColor: UIColor?
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if isPush {
            return 1
        } else {
            return 1
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        
        if isPush {
            // Get view controllers involved int he transition
            guard let fromVC = transitionContext.viewController(forKey: .from) as? BooksViewController,
                  let toVC = transitionContext.viewController(forKey: .to) as? BookViewController else { return }
            
            // Add toVC to the container
            container.addSubview(toVC.view)
            
            // Perform transition
            self.setStartPositionForPush(fromVC: fromVC, toVC: toVC)
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: {
                self.setEndPositionForPush(fromVC: fromVC, toVC: toVC)
            }, completion: { finished in
                self.cleanupPush(fromVC: fromVC, toVC: toVC)
                transitionContext.completeTransition(finished)
            })
        }
            
        else {
            // Get view controllers involved int he transition
            guard let fromVC = transitionContext.viewController(forKey: .from) as? BookViewController,
                  let toVC = transitionContext.viewController(forKey: .to) as? BooksViewController else { return }
            
            // Add toVC to the container
            container.insertSubview(toVC.view, belowSubview: fromVC.view)
            
            // Perform transition
            setStartPositionForPop(fromVC: fromVC, toVC: toVC)
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                self.setEndPositionForPop(fromVC: fromVC, toVC: toVC)
            }, completion: { finished in
                self.cleanupPop(fromVC: fromVC, toVC: toVC)
                transitionContext.completeTransition(finished)
            })
        }
    }
    
    // MARK: Push methods
    
    func setStartPositionForPush(fromVC: BooksViewController, toVC: BookViewController) {
        // Remove background from the pushed view controller
        toViewBackgroundColor = fromVC.collectionView?.backgroundColor
        toVC.collectionView?.backgroundColor = nil
        
        // Hide the selected book's cover. toVC will take care of displaying the cover image
        fromVC.selectedCell()?.alpha = 0
        
        // Loop through the pages of the book...
        for cell in toVC.collectionView!.visibleCells as! [BookPageCell] {
            // Save the current transform of the pages. This is the open position
            transforms[cell] = cell.layer.transform
            
            // Close book
            var transform = self.makePerspectiveTransform()
            // Right page
            if cell.layer.anchorPoint.x == 0 {
                // Adjust rotation
                transform = CATransform3DRotate(transform, CGFloat(0), 0, 1, 0)
                // Shift page to the center
                transform = CATransform3DTranslate(transform, -0.7 * cell.layer.bounds.width / 2, 0, 0)
                // Scale down to match the original cover size
                transform = CATransform3DScale(transform, 0.7, 0.7, 1)
            }
                // Left page
            else {
                // Adjust rotation
                transform = CATransform3DRotate(transform, CGFloat(-Double.pi), 0, 1, 0)
                // Shift page to the center
                transform = CATransform3DTranslate(transform, 0.7 * cell.layer.bounds.width / 2, 0, 0)
                // Scale down to match the original cover size
                transform = CATransform3DScale(transform, 0.7, 0.7, 1)
            }
            cell.layer.transform = transform
            cell.updateShadowLayer()
            
            // Ignore the shadow of the cover image.
            if let indexPath = toVC.collectionView?.indexPath(for: cell) {
                if indexPath.row == 0 {
                    cell.shadowLayer.opacity = 0
                }
            }
        }
    }
    
    func setEndPositionForPush(fromVC: BooksViewController, toVC: BookViewController) {
        // Fade out all other book covers
        for cell in fromVC.collectionView!.visibleCells as! [BookCoverCell] {
            cell.alpha = 0
        }
        
        // Open the book. Load the previously saved transforms
        for cell in toVC.collectionView!.visibleCells as! [BookPageCell] {
            cell.layer.transform = transforms[cell]!
            cell.updateShadowLayer(animated: true)
        }
    }
    
    func cleanupPush(fromVC: BooksViewController, toVC: BookViewController) {
        // Add background back to pushed view controller
        toVC.collectionView?.backgroundColor = self.toViewBackgroundColor
        
        // Pass the gesture recognizer
        toVC.recognizer = fromVC.recognizer
    }
    
    // MARK: Pop methods
    
    func setStartPositionForPop(fromVC: BookViewController, toVC: BooksViewController) {
        // Remove background from the pushed view controller
        toViewBackgroundColor = fromVC.collectionView?.backgroundColor
        fromVC.collectionView?.backgroundColor = nil
    }
    
    func setEndPositionForPop(fromVC: BookViewController, toVC: BooksViewController) {
        let coverCell = toVC.selectedCell()
        
        // Fade in all other book covers
        for cell in toVC.collectionView!.visibleCells as! [BookCoverCell] {
            if cell != coverCell {
                cell.alpha = 1
            }
        }
        
        // Close book
        for cell in fromVC.collectionView!.visibleCells as! [BookPageCell] {
            var transform = self.makePerspectiveTransform()
            // Right page
            if cell.layer.anchorPoint.x == 0 {
                // Adjust rotation
                transform = CATransform3DRotate(transform, CGFloat(0), 0, 1, 0)
                // Shift page to the center
                transform = CATransform3DTranslate(transform, -0.7 * cell.layer.bounds.width / 2, 0, 0)
                // Scale down to match the original cover size
                transform = CATransform3DScale(transform, 0.7, 0.7, 1)
            }
            // Left page
            else {
                // Adjust rotation
                transform = CATransform3DRotate(transform, CGFloat(-Double.pi), 0, 1, 0)
                // Shift page to the center
                transform = CATransform3DTranslate(transform, 0.7 * cell.layer.bounds.width / 2, 0, 0)
                // Scale down to match the original cover size
                transform = CATransform3DScale(transform, 0.7, 0.7, 1)
            }
            cell.layer.transform = transform
        }
    }
    
    func cleanupPop(fromVC: BookViewController, toVC: BooksViewController) {
        // Add background back to pushed view controller
        fromVC.collectionView?.backgroundColor = self.toViewBackgroundColor
        
        // Pass the gesture recognizer
        toVC.recognizer = fromVC.recognizer
        
        // Unhide the original book cover
        toVC.selectedCell()?.alpha = 1
    }
    
    // MARK: Stored properties
    
    var transforms = [UICollectionViewCell: CATransform3D]()
    
    // MARK: Helpers
    
    func makePerspectiveTransform() -> CATransform3D {
        var transform = CATransform3DIdentity;
        transform.m34 = 1.0 / -2000;
        return transform;
    }
    
}
