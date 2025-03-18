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
        
        // Register for orientation change notifications
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Handle orientation changes
    @objc func orientationDidChange() {
        // Calculate which page we're currently viewing
        let currentPage: Int
        if let collectionView = collectionView, collectionView.bounds.width > 0 {
            currentPage = Int(round(collectionView.contentOffset.x / collectionView.bounds.width))
        } else {
            currentPage = 0
        }
        
        // First, let the layout update
        collectionViewLayout.invalidateLayout()
        
        // Use a more controlled approach to update the collection view
        collectionView?.performBatchUpdates({
            // This will recalculate all layout information
            self.collectionView?.collectionViewLayout.invalidateLayout()
        }, completion: { _ in
            // After update, scroll to the same page (without animation to prevent jumps)
            if let collectionView = self.collectionView, collectionView.bounds.width > 0 {
                let targetX = CGFloat(currentPage) * collectionView.bounds.width
                // Use a safer approach that works even if contentSize has changed
                let safeX = min(targetX, max(0, collectionView.contentSize.width - collectionView.bounds.width))
                collectionView.setContentOffset(CGPoint(x: safeX, y: 0), animated: false)
            }
        })
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
