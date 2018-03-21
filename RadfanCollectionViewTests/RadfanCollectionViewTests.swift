//
//  RadfanCollectionViewTests.swift
//  RadfanCollectionViewTests
//
//  Created by Patrick Duvall on 2016-05-01.
//  Copyright © 2016 Patrick Duvall. All rights reserved.
//

import XCTest
@testable import RadfanCollectionView

class RadfanCollectionViewTests: XCTestCase {
    
    var layout: RadfanLayout!
    var viewController: RadfanDemoViewController!
    
    override func setUp() {
        super.setUp()
        
        layout = RadfanLayout()
        viewController = RadfanDemoViewController(collectionViewLayout: layout)
        viewController.collectionView?.bounds = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 667.0)
        layout.prepare()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCollectionViewContentSize() {
        //
        // Test that the contentView size of the collection view is equal to
        // the number of cells multiplied by the bounds width of the view itself
        //
        let numberOfItems = CGFloat( viewController.collectionView(viewController.collectionView!, numberOfItemsInSection: 0) )
        let collectionViewSize = viewController.collectionView!.bounds.size
        let contentSize = CGSize(width: numberOfItems*collectionViewSize.width, height: collectionViewSize.height)
        XCTAssertEqual(contentSize, layout.collectionViewContentSize)
    }
    
    func testLayoutAttributesForElementsInRect() {
        //
        // Test that we get layout elements for every cell if we
        // pass a rect that encompasses the entire collection view content size
        //
        
        let contentSize = layout.collectionViewContentSize
        let testRect = CGRect(x: 0.0, y: 0.0, width: contentSize.width, height: contentSize.height)
        let attributesArray = layout.layoutAttributesForElements(in: testRect)
        let numberOfCells = viewController.collectionView(viewController.collectionView!, numberOfItemsInSection: 0)
        
        XCTAssertEqual(numberOfCells, attributesArray?.count)
    }
    
    func testContentOffsetRoundsToNearestCell() {
        //
        // Test that the contentOffset correctly 'snaps to' the nearest
        // collection view cell
        //
        
        let collectionViewWidth = viewController.collectionView!.bounds.size.width
        
        //
        // Case 1: Proposed content offset is negative (left of the first collection view cell)
        // The expected offset should be the left ("start") of the view (0, 0)
        //
        let scrollVelocity1 = CGPoint(x: -1.0, y: 0)
        let proposedOffset1 = CGPoint(x: collectionViewWidth / -3, y: 0.0)
        let expectedOffset1 = CGPoint(x: 0.0, y: 0.0)
        XCTAssertEqual(expectedOffset1, layout.targetContentOffset(forProposedContentOffset: proposedOffset1, withScrollingVelocity: scrollVelocity1))
        
        //
        // Case 2: Proposed content offset is 1.6x the width of the view
        // The expected offset should be the third cell of the collection view (2 * collectionViewWidth, 0)
        //
        let scrollVelocity2 = CGPoint(x: 1.0, y: 0)
        let proposedOffset2 = CGPoint(x: collectionViewWidth * 1.6, y: 0.0)
        let expectedOffset2 = CGPoint(x: collectionViewWidth * 2.0, y: 0.0)
        XCTAssertEqual(expectedOffset2, layout.targetContentOffset(forProposedContentOffset: proposedOffset2, withScrollingVelocity: scrollVelocity2))
        
        //
        // Case 3: Proposed content offset is beyond the final collection view cell (on the right)
        // The expected offset should be the final cell of the collection view ((numberOfCells-1) * collectionViewWidth, 0)
        //
        let scrollVelocity3 = CGPoint(x: 1.0, y: 0)
        
        let numberOfCells = CGFloat( viewController.collectionView(viewController.collectionView!, numberOfItemsInSection: 0) )
        let proposedOffset3 = CGPoint(x: collectionViewWidth * (numberOfCells-0.51), y: 0.0)
        let expectedOffset3 = CGPoint(x: collectionViewWidth * (numberOfCells-1.0), y: 0.0)
        XCTAssertEqual(expectedOffset3, layout.targetContentOffset(forProposedContentOffset: proposedOffset3, withScrollingVelocity: scrollVelocity3))
    }
    
}
