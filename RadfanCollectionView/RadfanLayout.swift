//
//  RadfanLayout.swift
//  RadfanCollectionView
//
//  Created by Patrick Duvall on 2016-05-01.
//  Copyright © 2016 Patrick Duvall. All rights reserved.
//

import UIKit

// MARK: Constants

struct RadfanConstants {
    
    // padding insets between collection view cell and collection view
    struct Padding {
        static let portrait = CGSize(width: 25.0, height: 80.0)
        static let landscape = CGSize(width: 25.0, height: 40.0)
    }
    
    // constants for cell scrolling animation
    struct ScrollConstants {
        // set the vertical translation distance (use the sign to change direction)
        static let translation: CGFloat = 60.0
        
        // set the x and y scale factors during scrolling
        static let scaleX: CGFloat = 2.0
        static let scaleY: CGFloat = 0.4
        
        // set the rotation angle (in radians)
        static let rotate: CGFloat = .pi / 6.0
    }
}

// MARK: RadfanLayout 

class RadfanLayout: UICollectionViewLayout {
    
    private var oldBounds = CGRect.zero
    private var cache = [UICollectionViewLayoutAttributes]()
    
    override var collectionViewContentSize: CGSize {
        get {
            
            guard let collectionView = collectionView else {
                return CGSize.zero
            }
            
            // compute the content size for our collection view
            let width = collectionView.bounds.width * CGFloat( collectionView.numberOfItems(inSection: 0) )
            return CGSize(width: width, height: collectionView.bounds.height)
        }
    }

    override func prepare() {
        
        guard let collectionView = collectionView else {
            // nothing to do if we have a nil collection view
            return
        }
        
        // compute layout frames if we dont already have them in our cache

        if cache.isEmpty {
        
            let collectionViewSize = collectionView.bounds.size
            
            var padding = RadfanConstants.Padding.portrait
            if collectionViewSize.width > collectionViewSize.height {
                // landscape orientation
                padding = RadfanConstants.Padding.landscape
            }
            
            for i in 0 ..< collectionView.numberOfItems(inSection: 0) {
                
                let xOffset = CGFloat(i) * collectionViewSize.width
                let width = collectionViewSize.width
                let height = collectionViewSize.height
                
                // create the cell's frame at (xOffset, 0.0)
                let frame = CGRect(x: xOffset, y: 0.0, width: width, height: height)
                
                // add the padding to the cell's frame
                let frameWithPadding = frame.insetBy(dx: padding.width, dy: padding.height)
                
                let indexPath = IndexPath(item: i, section: 0)
                
                let layoutAttributes = layoutAttributesForItem(at: indexPath) ?? UICollectionViewLayoutAttributes(forCellWith: indexPath)
                layoutAttributes.frame = frameWithPadding
                
                // add the layout attributes to the cache array
                cache.append(layoutAttributes)
            }
            
        }
        
        // always compute the affine transforms for visible cells
        computeTransforms()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return cache.filter{ $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        return cache.filter{ $0.indexPath == indexPath }.first
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // clear the layout cache for a bounds change (ie: switching portrait <-> landscape)
        if oldBounds.size != newBounds.size {
            cache = []
            oldBounds = newBounds
        }
        return true
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        
        cache = []
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = collectionView else {
            return proposedContentOffset
        }
        
        // 'snap to' and center the nearest 'page' (collection view item)
        let pageWidth = collectionView.bounds.width
        let page = round(proposedContentOffset.x / pageWidth)
        
        return CGPoint(x: page * pageWidth, y: proposedContentOffset.y)
    }
    
    private func computeTransforms() {
        
        guard let collectionView = collectionView else {
            return
        }
        
        let collectionViewWidth = collectionView.bounds.width
        
        for indexPath in collectionView.indexPathsForVisibleItems {
            
            guard let layoutAttributes = layoutAttributesForItem(at: indexPath) else {
                // dont bother computing transforms if we dont even have a frame yet
                continue
            }
            
            //
            // Multiplier is a coefficient calculated using the cell's distance from the center
            // of the collection view; it determines how much to transform the cell.
            // (ie: a cell in the center has multiplier == 0.0, so it isn't transformed. abs(multiplier)
            // gets larger as the cell moves away from the center, and thus the effect of the transform
            // is more pronounced
            //
            let multiplier: CGFloat = (layoutAttributes.center.x - collectionView.contentOffset.x - collectionViewWidth/2.0) / collectionViewWidth
            let absMultiplier = abs(multiplier)
            
            // cells away from the center have alpha < 1.0
            layoutAttributes.alpha = 1.0 - absMultiplier

            // create our affine transformations for the cell and apply them
            
            // translation along y-axis
            var newTransform = CGAffineTransform(translationX: 0, y: absMultiplier * RadfanConstants.ScrollConstants.translation)

            // x and y scaling
            newTransform = newTransform.scaledBy(x: 1.0 - RadfanConstants.ScrollConstants.scaleX * absMultiplier, y: 1.0 - RadfanConstants.ScrollConstants.scaleY * absMultiplier)

            // rotation
            newTransform = newTransform.rotated(by: multiplier * RadfanConstants.ScrollConstants.rotate)
            
            layoutAttributes.transform = newTransform
        }
    }
}
