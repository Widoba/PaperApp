//
//  BookPageCell.swift
//  RW - Paper
//
//  Created by Attila on 2014. 12. 01..
//  Copyright (c) 2014. -. All rights reserved.
//

import UIKit

class BookPageCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var book: Book?
    var isRightPage: Bool = false
    var shadowLayer = CAGradientLayer()
    
    var image: UIImage? {
        didSet {
            guard let image = image else { return }
            let corners: UIRectCorner = isRightPage ? [.topRight, .bottomRight] : [.topLeft, .bottomLeft]
            imageView.image = image.imageByScalingAndCroppingForSize(targetSize: bounds.size).imageWithRoundedCornersSize(cornerRadius: 20, corners: corners)
        }
    }
    
    func updateShadowLayer(animated: Bool = false) {
        // Get ratio from transform. Check BookCollectionViewLayout for more details
        let inverseRatio = 1 - abs(getRatioFromTransform())
        
        if !animated {
            CATransaction.begin()
            CATransaction.setDisableActions(!animated)
        }
        
        if isRightPage {
            // Right page
            shadowLayer.colors = [
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.45).cgColor,
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.40).cgColor,
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.55).cgColor
            ]
            shadowLayer.locations = [
                NSNumber(value: 0.00),
                NSNumber(value: 0.02),
                NSNumber(value: 1.00)
            ] as [NSNumber]
        } else {
            // Left page
            shadowLayer.colors = [
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.55).cgColor,
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.40).cgColor,
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.45).cgColor
            ]
            shadowLayer.locations = [
                NSNumber(value: 0.00),
                NSNumber(value: 0.98),
                NSNumber(value: 1.00)
            ] as [NSNumber]
        }
        
        if !animated {
            CATransaction.commit()
        }
    }
    
    func getRatioFromTransform() -> CGFloat {
        var ratio: CGFloat = 0
        
        let rotationY = CGFloat((layer.value(forKeyPath: "transform.rotation.y") as! NSNumber).floatValue)
        if isRightPage {
            let progress = -(1 - rotationY / CGFloat(Double.pi / 2))
            ratio = progress
        }
            
        else {
            let progress = 1 - rotationY / CGFloat(-Double.pi / 2)
            ratio = progress
        }
        
        return ratio
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAntialiasing()
        initShadowLayer()
    }
    
    func setupAntialiasing() {
        layer.allowsEdgeAntialiasing = true
        imageView.layer.allowsEdgeAntialiasing = true
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let rotationY = CGFloat((layer.value(forKeyPath: "transform.rotation.y") as! NSNumber).floatValue)
        let wasRightPage = isRightPage
        isRightPage = rotationY < CGFloat(0)
        
        // If the page orientation changed, update the image to apply correct rounded corners
        if wasRightPage != isRightPage && image != nil {
            // This will trigger the didSet which applies the correct corners
            let currentImage = image
            image = currentImage
        }
        
        // Set anchor point based on which side of the book's spine the page is on
        if isRightPage {
            // Right page - spine is on the left, so anchor point should be left edge
            layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        } else {
            // Left page - spine is on the right, so anchor point should be right edge
            layer.anchorPoint = CGPoint(x: 1, y: 0.5)
        }
        
        shadowLayer.frame = bounds
    }

    func initShadowLayer() {
        let shadowLayer = CAGradientLayer()
        
        shadowLayer.frame = bounds
        shadowLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shadowLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        self.imageView.layer.addSublayer(shadowLayer)
        self.shadowLayer = shadowLayer
    }
    
    override var bounds: CGRect {
        didSet {
            shadowLayer.frame = bounds
        }
    }
    
}
