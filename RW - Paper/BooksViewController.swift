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
        
        // Set background color for the entire view
        view.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        collectionView.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        
        // Set up edge-to-edge layout
        setupEdgeToEdgeLayout()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Handle orientation changes
    @objc func orientationDidChange() {
        // Store current position
        let currentOffsetRatio: CGFloat = collectionView.contentOffset.x / max(collectionView.contentSize.width, 1)
        
        // Re-setup edge-to-edge layout
        setupEdgeToEdgeLayout()
        
        // Force layout update
        collectionViewLayout.invalidateLayout()
        
        // Wait for layout to update and then restore position
        DispatchQueue.main.async {
            // Calculate new offset after layout update
            let newOffsetX = currentOffsetRatio * self.collectionView.contentSize.width
            self.collectionView.setContentOffset(CGPoint(x: newOffsetX, y: 0), animated: false)
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
    
    private func setupEdgeToEdgeLayout() {
        // Extend layout under bars and safe areas
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        
        // Set status bar appearance to ensure proper extension
        setNeedsStatusBarAppearanceUpdate()
        
        // Make sure window background color matches view
        if let window = UIApplication.shared.windows.first {
            window.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        }
        
        // Ensure collection view extends to edges
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
            view.insetsLayoutMarginsFromSafeArea = false
            collectionView.insetsLayoutMarginsFromSafeArea = false
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        // Hide navigation bar to maximize space
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Make sure collection view uses full bounds
        view.layoutIfNeeded()
        collectionView.frame = UIScreen.main.bounds // Use screen bounds instead of view bounds
        
        // Remove any additional insets
        collectionView.contentInset = UIEdgeInsets.zero
        collectionView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    // Add status bar style control
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
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
