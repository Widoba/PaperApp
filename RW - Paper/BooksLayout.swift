//
//  BooksLayout.swift
//  RW - Paper
//
//  Created by Attila on 2014. 12. 06..
//  Copyright (c) 2014. -. All rights reserved.
//

import UIKit

// Replace fixed values with calculated properties based on device size
class BooksLayout: UICollectionViewFlowLayout {
    
    var numberOfItems = 0
    
    // Dynamic page dimensions based on the device size
    private var pageWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Determine if we're in portrait or landscape
        let isPortrait = screenHeight > screenWidth
        
        // Original book aspect ratio is 362:568 or approximately 0.637:1
        let originalAspectRatio: CGFloat = 362.0 / 568.0
        
        // Calculate dimensions based on filling the screen while maintaining aspect ratio
        if isPortrait {
            // In portrait, use almost full width
            let maxWidth = screenWidth * 0.95
            return maxWidth
        } else {
            // In landscape, determine width based on height
            let maxHeight = screenHeight * 0.95
            return maxHeight * originalAspectRatio
        }
    }
    
    private var pageHeight: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Determine if we're in portrait or landscape
        let isPortrait = screenHeight > screenWidth
        
        // Original book aspect ratio is 362:568 or approximately 0.637:1
        let originalAspectRatio: CGFloat = 568.0 / 362.0
        
        // Calculate dimensions based on filling the screen while maintaining aspect ratio
        if isPortrait {
            // In portrait, height is determined by width
            return pageWidth * originalAspectRatio
        } else {
            // In landscape, use almost full height
            return screenHeight * 0.95
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        scrollDirection = UICollectionView.ScrollDirection.horizontal
        // Use the dynamic size properties instead of fixed constants
        itemSize = CGSize(width: pageWidth, height: pageHeight)
        minimumInteritemSpacing = 10
    }
    
    override func prepare() {
        super.prepare()
        
        collectionView?.decelerationRate = UIScrollView.DecelerationRate.fast
        
        // Make sure the first book is centered.
        collectionView?.contentInset = UIEdgeInsets(
            top: 0,
            left: collectionView!.bounds.width / 2 - pageWidth / 2,
            bottom: 0,
            right: collectionView!.bounds.width / 2 - pageWidth / 2
        )
        
        numberOfItems = collectionView!.numberOfItems(inSection: 0)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let array = super.layoutAttributesForElements(in: rect) else { return nil }
        
        for attributes in array {
            let frame = attributes.frame
            let distance = abs(collectionView!.contentOffset.x + collectionView!.contentInset.left - frame.origin.x)
            let scale = 0.7 * min(max(1 - distance / (collectionView!.bounds.width), 0.75), 1)
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        return array
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        // Snap cells to centre
        var newOffset = CGPoint()
        
        guard let layout = collectionView!.collectionViewLayout as? UICollectionViewFlowLayout else { return proposedContentOffset }
        let width = layout.itemSize.width + layout.minimumLineSpacing
        var offset = proposedContentOffset.x + collectionView!.contentInset.left
        
        if velocity.x > 0 {
            offset = width * ceil(offset / width)
        }
        
        if velocity.x == 0 {
            offset = width * round(offset / width)
        }
        
        if velocity.x < 0 {
            offset = width * floor(offset / width)
        }
        
        newOffset.x = offset - collectionView!.contentInset.left
        newOffset.y = proposedContentOffset.y
        
        return newOffset
    }
}
