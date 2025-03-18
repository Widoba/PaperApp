//
//  BooksViewController.swift
//  RW - Paper
//
//  Created by Attila on 2014. 12. 06..
//  Copyright (c) 2014. -. All rights reserved.
//

import UIKit

class BooksViewController: UICollectionViewController {
    
    var books: Array<Book>? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var transition: BookOpeningTransition?
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    var recognizer: UIGestureRecognizer? {
        didSet {
            if let recognizer = recognizer {
                collectionView?.addGestureRecognizer(recognizer)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        books = BookStore.sharedInstance.loadBooks(plist: "Books")
        recognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        
        // Register for orientation change notifications
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Handle orientation changes
    @objc func orientationDidChange() {
        // Store the current content offset ratio before layout changes
        let currentOffsetRatio: CGFloat
        if let collectionView = collectionView, collectionView.contentSize.width > 0 {
            currentOffsetRatio = collectionView.contentOffset.x / collectionView.contentSize.width
        } else {
            currentOffsetRatio = 0
        }
        
        // Save the current centered book
        let currentBook = selectedCell()
        
        // Force layout update - need to explicitly update the flow layout
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            // Update item size for the new orientation
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            let isPortrait = screenHeight > screenWidth
            
            // Recalculate content insets for new orientation
            if let layout = collectionViewLayout as? BooksLayout {
                collectionView?.performBatchUpdates({
                    // This triggers layout recalculation
                    layout.invalidateLayout()
                }, completion: { _ in
                    // After layout is updated, restore position
                    if let currentBook = currentBook, let indexPath = self.collectionView?.indexPath(for: currentBook) {
                        // Scroll to the previously selected book
                        self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                    }
                })
            }
        } else {
            // Fallback to simple invalidation
            collectionViewLayout.invalidateLayout()
            collectionView?.reloadData()
            
            // Try to maintain the same position after reload
            if let currentBook = currentBook, let indexPath = self.collectionView?.indexPath(for: currentBook) {
                self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }
        }
    }
    
    // MARK: Helpers
    
    func selectedCell() -> BookCoverCell? {
        if let indexPath = collectionView?.indexPathForItem(at: CGPoint(x: collectionView!.contentOffset.x + collectionView!.bounds.width / 2, y: collectionView!.bounds.height / 2)) {
            if let cell = collectionView?.cellForItem(at: indexPath) as? BookCoverCell {
                return cell
            }
        }
        return nil
    }
    
    // MARK: Gesture recognizer action
    
    @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if recognizer.scale >= 1 {
                if recognizer.view == collectionView {
                    interactionController = UIPercentDrivenInteractiveTransition()
                    let book = self.selectedCell()?.book
                    self.openBook(book: book)
                }
            }
            
            else {
                interactionController = UIPercentDrivenInteractiveTransition()
                navigationController?.popViewController(animated: true)
            }
            
        case .changed:
            if transition!.isPush {
                let progress = min(max(abs((recognizer.scale - 1)) / 5, 0), 1)
                interactionController?.update(progress)
            }
            else {
                let progress = min(max(abs((1 - recognizer.scale)), 0), 1)
                interactionController?.update(progress)
            }
            
        case .ended:
            interactionController?.finish()
            interactionController = nil
            
        default:
            break
        }
    }
    
    func openBook(book: Book?) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "BookViewController") as! BookViewController
        vc.book = selectedCell()?.book
        // UICollectionView loads it's cells on a background thread, so make sure it's loaded before passing it to the animation handler
        vc.view.snapshotView(afterScreenUpdates: true)
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
    }
    
    // MARK: UICollectionViewDataSource & UICollectionViewDelegate methods
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let books = books {
            return books.count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCoverCell", for: indexPath) as! BookCoverCell
        
        cell.book = books?[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = books?[indexPath.row]
        openBook(book: book)
    }
}

// MARK: UIViewControllerAnimatedTransitioning

extension BooksViewController {
    
    // Updated method names to match the modern Swift UIKit signature expected by CustomNavigationViewController
    func animationControllerForPresentController(vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = BookOpeningTransition()
        transition.isPush = true
        transition.interactionController = interactionController
        self.transition = transition
        return transition
    }
    
    func animationControllerForDismissController(vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = BookOpeningTransition()
        transition.isPush = false
        transition.interactionController = interactionController
        self.transition = transition
        return transition
    }
}
