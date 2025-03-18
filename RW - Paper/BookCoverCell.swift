//
//  BookCoverCell.swift
//  RW - Paper
//
//  Created by Attila on 2014. 12. 06..
//  Copyright (c) 2014. -. All rights reserved.
//

import UIKit

class BookCoverCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var book: Book? {
        didSet {
            image = book?.coverImage()
        }
    }
    
    var image: UIImage? {
        didSet {
            guard let image = image else { return }
            let corners: UIRectCorner = [.topRight, .bottomRight]
            imageView.image = image.imageByScalingAndCroppingForSize(targetSize: bounds.size).imageWithRoundedCornersSize(cornerRadius: 20, corners: corners)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAntialiasing()
        
        // Set the anchor point to the right edge (spine of the book)
        layer.anchorPoint = CGPoint(x: 1, y: 0.5)
    }
    
    func setupAntialiasing() {
        layer.allowsEdgeAntialiasing = true
        imageView.layer.allowsEdgeAntialiasing = true
    }
    
}
