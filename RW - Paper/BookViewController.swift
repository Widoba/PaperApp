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
        
        print("BookViewController - After setupEdgeToEdgeLayout, view frame: \(view.frame)")
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
        
        // Force background color
        view.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        collectionView.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        
        // Hide navigation bar completely
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        print("BookViewController - viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("BookViewController - viewDidAppear frame: \(view.frame)")
        print("BookViewController - CollectionView frame: \(collectionView.frame)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Make sure content insets are zero
        collectionView.contentInset = .zero
        
        // Force layout update
        collectionViewLayout.invalidateLayout()
        
        print("BookViewController - viewDidLayoutSubviews, collection view frame: \(collectionView.frame)")
    }
}

// MARK: UICollectionViewDataSource

extension BookViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Add safeguard for nil book
        guard let book = book else {
            print("BookViewController - Warning: book is nil in numberOfItemsInSection")
            return 0
        }
        
        // Add bounds check and safeguard
        let count = book.numberOfPages() + 1
        print("BookViewController - Number of items: \(count)")
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("BookViewController - cellForItemAt called for indexPath: \(indexPath)")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookPageCell", for: indexPath) as! BookPageCell
        
        // Add safeguards around book access
        guard let book = self.book else {
            print("BookViewController - Warning: book is nil in cellForItemAt")
            // Configure cell with placeholder or empty state
            cell.textLabel.text = "Error"
            cell.image = nil
            return cell
        }
        
        // Log book information for debugging
        print("BookViewController - Book has \(book.numberOfPages()) pages")
        
        // Add bounds checking
        if indexPath.row == 0 {
            // Cover page
            print("BookViewController - Configuring cover page cell")
            cell.textLabel.text = nil
            cell.image = book.coverImage()
        }
        else if indexPath.row <= book.numberOfPages() {
            // Page with index: indexPath.row - 1
            print("BookViewController - Configuring page \(indexPath.row) cell")
            cell.textLabel.text = "\(indexPath.row)"
            cell.image = book.pageImage(index: indexPath.row - 1)
        }
        else {
            // Handle out of bounds index
            print("BookViewController - Warning: Index out of bounds: \(indexPath.row)")
            cell.textLabel.text = "Error"
            cell.image = nil
        }
        
        return cell
    }
    
}
