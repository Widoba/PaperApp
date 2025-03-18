//
//  BookLayout.swift
//  RW - Paper
//
//  Created by Attila on 2014. 12. 01..
//  Copyright (c) 2014. -. All rights reserved.
//

import UIKit

private let PageWidth: CGFloat = 362
private let PageHeight: CGFloat = 568

class BookLayout: UICollectionViewLayout {
   
    var numberOfItems = 0
    
    override func prepare() {
        super.prepare()
        collectionView?.decelerationRate = UIScrollView.DecelerationRate.fast
        numberOfItems = collectionView!.numberOfItems(inSection: 0)
        collectionView?.isPagingEnabled = true
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Make sure to update the layout if the bounds change
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: (CGFloat(numberOfItems / 2)) * collectionView!.bounds.width, height: collectionView!.bounds.height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var array: [UICollectionViewLayoutAttributes] = []
        for i in 0 ... max(0, numberOfItems - 1) {
            let indexPath = IndexPath(item: i, section: 0)
            if let attributes = layoutAttributesForItem(at: indexPath) {
                array.append(attributes)
            }
        }
        return array
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // Create layout attributes object
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        // Set initial frame - align the page's edge to the spine
        let frame = getFrame(collectionView!)
        layoutAttributes.frame = frame
        
        // Calculate ratio.
        //
        // What is ratio?
        //  - Let's imagine an opened book layed on a table. When you take a page on the right side and turn it to left, the ratio goes from 1.0 to -1.0
        //
        //     1.0:  0' angle. The page is turned right, parallel to the table.
        //     0.5: 45' angle.
        //     0.0: 90' angle. The page is vertical to the table, 90' angle
        //    -0.5: 45' angle.
        //    -1.0:  0' angle. The page is turned left, parallel to the table
        let ratio = getRatio(collectionView!, indexPath: indexPath)
        
        // Filter pages beyond the given threshold
        if ratio < -1 || 1 < ratio  {
            // Make sure the cover is always visible
            if indexPath.row != 0 {
                return nil
            }
        }
        
        // Back-face culling - display only front-face pages.
        if ratio > 0 && indexPath.item % 2 == 1
            || ratio < 0 && indexPath.item % 2 == 0 {
            // Make sure the cover is always visible
            if indexPath.row != 0 {
                return nil
            }
        }
        
        // Apply rotation transform
        let rotation = getRotation(indexPath, ratio: min(max(ratio, -1), 1))
        layoutAttributes.transform3D = rotation
        
        // Set z-index
        layoutAttributes.zIndex = Int(1000 * (1 - abs(ratio)))
        
        // Make sure the cover is always above page 1 to avoid flickering when closing the book
        if indexPath.row == 0 {
            layoutAttributes.zIndex = Int.max
        }
        
        return layoutAttributes
    }
    
    // MARK: Helpers
    
    func getFrame(_ collectionView: UICollectionView) -> CGRect {
        var frame = CGRect()
        
        frame.origin.x = collectionView.bounds.width / 2 - PageWidth / 2 + collectionView.contentOffset.x
        frame.origin.y = (collectionViewContentSize.height - PageHeight) / 2
        frame.size.width = PageWidth
        frame.size.height = PageHeight
        
        return frame
    }
    
    func getRatio(_ collectionView: UICollectionView, indexPath: IndexPath) -> CGFloat {
        let page = CGFloat(indexPath.item - indexPath.item % 2)
        var ratio: CGFloat = -0.5 + 0.5 * page - collectionView.contentOffset.x / collectionView.bounds.width
        
        if ratio > 0.5 {
            ratio = 0.5 + 0.1 * (ratio - 0.5)
        }
        
        if ratio < -0.5 {
            ratio = -0.5 + 0.1 * (ratio + 0.5)
        }
        
        return ratio
    }
    
    func getRotation(_ indexPath: IndexPath, ratio: CGFloat) -> CATransform3D {
        var transform = makePerspectiveTransform()
        
        // Set rotation
        var angle: CGFloat = 0
        
        if indexPath.item % 2 == 0 {
            // The book's spine is on the left of the page
            angle = (1-ratio) * CGFloat(-Double.pi/2)
            
            // Make sure the odd and even page don't have the exact same angle
            angle += CGFloat(indexPath.row % 2) / 1000
        }
        
        if indexPath.item % 2 == 1 {
            // The book's spine is on the right of the page
            angle = CGFloat(Double.pi/2) + ratio * CGFloat(Double.pi/2)
            
            // Make sure the odd and even page don't have the exact same angle
            angle += CGFloat(indexPath.row % 2) / 1000
        }
        
        transform = CATransform3DRotate(transform, angle, 0, 1, 0)
        
        return transform
    }
    
    func makePerspectiveTransform() -> CATransform3D {
        var transform = CATransform3DIdentity;
        transform.m34 = 1.0 / -2000;
        return transform;
    }
    
}
