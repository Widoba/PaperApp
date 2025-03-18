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
        
        print("BooksViewController - viewDidLoad")
        print("BooksViewController - Screen bounds: \(UIScreen.main.bounds)")
        print("BooksViewController - Initial view frame: \(view.frame)")
        
        // Setup
        setupGestureRecognizer()
        setupEdgeToEdgeLayout()

        // Add notification for orientation change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        // Print collection view details
        if let collectionView = self.collectionView {
            print("BooksViewController - CollectionView frame: \(collectionView.frame)")
            print("BooksViewController - CollectionView contentInset: \(collectionView.contentInset)")
            
            // Ensure collection view fills the screen
            collectionView.frame = UIScreen.main.bounds
            collectionView.contentInsetAdjustmentBehavior = .never
            
            print("BooksViewController - After setting frame, CollectionView frame: \(collectionView.frame)")
        }
        
        // Load books
        books = BookStore.sharedInstance.loadBooks(plist: "Books")
        
        // Recognizer is already set up in setupGestureRecognizer()
        // recognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        
        // Set background color for the entire view
        view.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        collectionView.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
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
    
    private func setupGestureRecognizer() {
        // Create and add the pinch gesture recognizer
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        self.recognizer = pinchRecognizer
        
        print("BooksViewController - Added pinch gesture recognizer")
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
            // Add a guard to make sure transition is not nil before using it
            guard let transition = transition else {
                print("BooksViewController - Warning: transition is nil in handlePinch")
                return
            }
            
            if transition.isPush {
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
        print("BooksViewController - openBook called")
        
        guard let storyboard = self.storyboard else {
            print("BooksViewController - ERROR: Storyboard is nil in openBook")
            return
        }
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BookViewController") as? BookViewController else {
            print("BooksViewController - ERROR: Failed to instantiate BookViewController")
            return
        }
        
        guard let selectedBook = selectedCell()?.book else {
            print("BooksViewController - Warning: Selected book is nil")
            // We'll still continue, but log the warning
            return
        }
        
        print("BooksViewController - Setting book for BookViewController")
        vc.book = selectedBook
        
        // UICollectionView loads its cells on a background thread, so make sure it's loaded before passing it to the animation handler
        print("BooksViewController - Creating snapshot for smooth transition")
        _ = vc.view.snapshotView(afterScreenUpdates: true)
        
        guard let navigationController = self.navigationController else {
            print("BooksViewController - ERROR: Navigation controller is nil")
            return
        }
        
        print("BooksViewController - Pushing BookViewController to navigation stack")
        DispatchQueue.main.async {
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: UICollectionViewDataSource & UICollectionViewDelegate methods
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let books = books, !books.isEmpty else {
            print("BooksViewController - Warning: books array is nil or empty")
            return 0
        }
        
        let count = books.count
        print("BooksViewController - Number of items: \(count)")
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCoverCell", for: indexPath) as! BookCoverCell
        
        guard let books = self.books, indexPath.row < books.count else {
            print("BooksViewController - Warning: Invalid book index: \(indexPath.row)")
            // Configure cell with placeholder or empty state
            cell.book = nil
            return cell
        }
        
        cell.book = books[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = books?[indexPath.row]
        openBook(book: book)
    }
    
    private func setupEdgeToEdgeLayout() {
        // Configure for edge-to-edge layout
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        
        // Disable safe area adjustments
        if #available(iOS 11.0, *) {
            // Disable content inset adjustment
            collectionView?.contentInsetAdjustmentBehavior = .never
            
            // Reset any additional safe area insets
            additionalSafeAreaInsets = .zero
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        // Hide the navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Apply auto layout constraints to ensure collection view fills the screen
        if let collectionView = collectionView {
            // IMPORTANT: Don't mix frame and auto layout approaches
            // We'll use just auto layout here
            
            // Set translatesAutoresizingMaskIntoConstraints to false for auto layout
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            
            // Remove any existing constraints first to avoid conflicts
            let existingConstraints = view.constraints.filter {
                ($0.firstItem === collectionView || $0.secondItem === collectionView)
            }
            view.removeConstraints(existingConstraints)
            
            // Add constraints to make collection view fill the entire view
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        print("BooksViewController - After setupEdgeToEdgeLayout, view frame: \(view.frame)")
    }
    
    // Add status bar style control
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Force background color
        view.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        collectionView.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        
        // Hide navigation bar completely
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        print("BooksViewController - viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("BooksViewController - viewDidAppear frame: \(view.frame)")
        print("BooksViewController - CollectionView frame: \(collectionView?.frame ?? .zero)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Make sure content insets are zero
        collectionView.contentInset = .zero
        
        // Force layout update
        collectionViewLayout.invalidateLayout()
        
        print("BooksViewController - viewDidLayoutSubviews, collection view frame: \(collectionView?.frame ?? .zero)")
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
