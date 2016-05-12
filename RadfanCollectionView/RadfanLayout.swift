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
        static let portrait: CGSize = CGSize(width: 25.0, height: 80.0)
        static let landscape: CGSize = CGSize(width: 25.0, height: 40.0)
    }
    
    // constants for cell scrolling animation
    struct ScrollConstants {
        // set the vertical translation distance (use the sign to change direction)
        static let translation: CGFloat = 60.0
        
        // set the x and y scale factors during scrolling
        static let scaleX: CGFloat = 2.0
        static let scaleY: CGFloat = 0.4
        
        // set the rotation angle (in radians)
        static let rotate: CGFloat = CGFloat(M_PI) / 6.0
    }
}

// MARK: RadfanLayout 

class RadfanLayout: UICollectionViewLayout {
    
    private var oldBounds: CGRect = CGRect.zero
    private var cache = [UICollectionViewLayoutAttributes]()

    override func prepareLayout() {
        
        // always compute the affine transforms for visible cells
        self.computeTransforms()
        
        if (!cache.isEmpty) {
            // dont recalculate the entire layout if we have an existing cache of attributes
            return;
        }
        
        let collectionViewSize = collectionView!.bounds.size
        
        var padding = RadfanConstants.Padding.portrait
        if (collectionViewSize.width > collectionViewSize.height) {
            // landscape orientation
            padding = RadfanConstants.Padding.landscape
        }
        
        for i in 0 ..< collectionView!.numberOfItemsInSection(0) {
            
            let xOffset = CGFloat(i) * collectionViewSize.width
            let width = collectionViewSize.width
            let height = collectionViewSize.height
            
            // create the cell's frame at (xOffset, 0.0)
            let frame = CGRect(x: xOffset, y: 0.0, width: width, height: height)
            // add the padding to the cell's frame
            let frameWithPadding = CGRectInset(frame, padding.width, padding.height)
            
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let layoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            layoutAttributes.frame = frameWithPadding
            
            // add the layout attributes to the cache array
            cache.append(layoutAttributes)
            
        }
        
    }
    
    override func collectionViewContentSize() -> CGSize {
        // compute the content size for our collection view
        let width = collectionView!.bounds.size.width * CGFloat( collectionView!.numberOfItemsInSection(0) )
        return CGSizeMake(width, collectionView!.bounds.size.height)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if (attributes.frame.intersects(rect)) {
                // if the layoutattributes frame is within the 'rect' parameter, 
                // add it to our array of attributes to return
                layoutAttributes.append(attributes)
            }
        }
        
        return layoutAttributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        // clear the layout cache for a bounds change (ie: switching portrait <-> landscape)
        if (oldBounds.size != newBounds.size) {
            cache = [UICollectionViewLayoutAttributes]()
            oldBounds = newBounds
        }
        return true;
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        // 'snap to' and center the nearest 'page' (collection view item)
        let pageWidth = collectionView!.bounds.size.width
        let page = round(proposedContentOffset.x / pageWidth)
        return CGPointMake(page * pageWidth, proposedContentOffset.y)
    }
    
    private func computeTransforms() {
        for cell in collectionView!.visibleCells() {
            let collectionViewWidth = collectionView!.bounds.size.width
            
            //
            // Multiplier is a coefficient calculated using the cell's distance from the center
            // of the collection view; it determines how much to transform the cell.
            // (ie: a cell in the center has multiplier == 0.0, so it isn't transformed. abs(multiplier)
            // gets larger as the cell moves away from the center, and thus the effect of the transform
            // is more pronounced
            //
            let multiplier: CGFloat = (cell.center.x - collectionView!.contentOffset.x - collectionViewWidth/2.0) / collectionViewWidth
            
            // cells away from the center have alpha < 1.0
            cell.alpha = 1.0 - abs(multiplier)
            
            // create our affine transformations for the cell and apply them
            var newTransform = CGAffineTransformMakeTranslation(0.0, abs(multiplier)*RadfanConstants.ScrollConstants.translation)
            newTransform = CGAffineTransformScale(newTransform, 1.0-RadfanConstants.ScrollConstants.scaleX*abs(multiplier), 1.0-RadfanConstants.ScrollConstants.scaleY*abs(multiplier))
            cell.transform = CGAffineTransformRotate(newTransform, multiplier*RadfanConstants.ScrollConstants.rotate)
        }
    }

}
