//
//  ViewController.swift
//  RW - Paper
//
//  Created by Attila on 2014. 12. 01..
//  Copyright (c) 2014. -. All rights reserved.
//

import UIKit

class BookViewController: UICollectionViewController {
    
    var book: Book? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var recognizer: UIGestureRecognizer? {
        didSet {
            if let recognizer = recognizer {
                collectionView?.addGestureRecognizer(recognizer)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("BookViewController - viewDidLoad")
        print("BookViewController - Screen bounds: \(UIScreen.main.bounds)")
        print("BookViewController - Initial view frame: \(view.frame)")
        
        // Set up our view
        setupEdgeToEdgeLayout()
        
        // Add notification for orientation change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification, 
            object: nil
        )
        
        self.pages = book.pages
        
        // Set background color
        view.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        collectionView.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        
        // Print collection view details
        print("BookViewController - CollectionView frame: \(collectionView.frame)")
        print("BookViewController - CollectionView contentInset: \(collectionView.contentInset)")
    }
    
    func setupEdgeToEdgeLayout() {
        // Extend layout under bars and safe areas
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        
        // Set view to use full screen bounds
        view.frame = UIScreen.main.bounds
        
        // Disable safe area adjustments
        if #available(iOS 11.0, *) {
            // Disable content inset adjustment
            collectionView.contentInsetAdjustmentBehavior = .never
            
            // Reset any additional safe area insets
            additionalSafeAreaInsets = .zero
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        // Hide the navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Ensure collection view fills the screen
        collectionView.frame = UIScreen.main.bounds
        
        print("BookViewController - After setupEdgeToEdgeLayout, view frame: \(view.frame)")
        print("BookViewController - CollectionView frame: \(collectionView.frame)")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Update layout when orientation changes
    @objc func orientationDidChange() {
        // Calculate current page based on content offset and item size
        let currentPage = Int(round(collectionView.contentOffset.x / collectionView.bounds.width))
        
        // Re-setup edge-to-edge layout
        setupEdgeToEdgeLayout()
        
        // Force layout update
        collectionViewLayout.invalidateLayout()
        
        // Wait for layout to update with correct dimensions
        DispatchQueue.main.async {
            // Calculate the offset for the same page
            let pageOffset = CGFloat(currentPage) * self.collectionView.bounds.width
            let safeOffset = min(pageOffset, self.collectionView.contentSize.width - self.collectionView.bounds.width)
            let finalOffset = max(0, safeOffset)
            
            // Set the content offset to maintain the same page
            self.collectionView.setContentOffset(CGPoint(x: finalOffset, y: 0), animated: false)
        }
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
        
        // Force edge-to-edge layout
        view.frame = UIScreen.main.bounds
        collectionView.frame = UIScreen.main.bounds
        
        print("BookViewController - viewWillAppear frame: \(view.frame)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("BookViewController - viewDidAppear frame: \(view.frame)")
        print("BookViewController - CollectionView frame: \(collectionView.frame)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set collection view frame to window bounds, not view bounds
        if let window = UIApplication.shared.windows.first {
            let fullScreenBounds = window.bounds
            collectionView.frame = fullScreenBounds
        } else {
            collectionView.frame = UIScreen.main.bounds
        }
        
        // Make sure content insets are zero
        collectionView.contentInset = .zero
        
        // Force layout update
        collectionViewLayout.invalidateLayout()
    }
}

// MARK: UICollectionViewDataSource

extension BookViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let book = book {
            return book.numberOfPages() + 1
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookPageCell", for: indexPath) as! BookPageCell
        
        if indexPath.row == 0 {
            // Cover page
            cell.textLabel.text = nil
            cell.image = book?.coverImage()
        }
        else {
            // Page with index: indexPath.row - 1
            cell.textLabel.text = "\(indexPath.row)"
            cell.image = book?.pageImage(index: indexPath.row - 1)
        }
        
        return cell
    }
    
}
