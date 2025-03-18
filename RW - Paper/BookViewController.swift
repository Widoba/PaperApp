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
        
        // Apply full screen setup
        configureFullScreenDisplay()
        
        // Set background color for the entire view
        view.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        collectionView.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        
        setupEdgeToEdgeLayout()
        
        // Register for orientation change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    private func configureFullScreenDisplay() {
        // Set collection view to use the full screen
        if let collectionView = collectionView {
            // Extend beyond safe areas
            if #available(iOS 11.0, *) {
                collectionView.contentInsetAdjustmentBehavior = .never
            } else {
                automaticallyAdjustsScrollViewInsets = false
            }
            
            // Set the frame to match the screen bounds exactly
            let fullScreenFrame = UIScreen.main.bounds
            view.frame = fullScreenFrame
            collectionView.frame = fullScreenFrame
            
            // Update collection view layout
            if let layout = collectionViewLayout as? BookLayout {
                layout.invalidateLayout()
            }
        }
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
        
        // Force the view to fill the screen by directly setting its frame to screen bounds
        view.frame = UIScreen.main.bounds
        
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
        
        // Make sure collection view uses full screen bounds - important!
        view.layoutIfNeeded()
        collectionView.frame = UIScreen.main.bounds
        
        // Remove any additional insets
        collectionView.contentInset = UIEdgeInsets.zero
        collectionView.scrollIndicatorInsets = UIEdgeInsets.zero
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
        
        // Force view to use full screen bounds
        let fullScreenBounds = UIScreen.main.bounds
        view.frame = fullScreenBounds
        
        // Force background color
        view.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        view.superview?.backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
        
        // Hide navigation bar completely
        navigationController?.setNavigationBarHidden(true, animated: false)
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
