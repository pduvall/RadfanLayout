//
//  RadfanDemoViewController.swift
//  RadfanCollectionView
//
//  Created by Patrick Duvall on 2016-05-01.
//  Copyright © 2016 Patrick Duvall. All rights reserved.
//

import UIKit

class RadfanDemoViewController: UICollectionViewController {
    
    let colors = [UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor()]

    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
}

// MARK: UICollectionViewDataSource

extension RadfanDemoViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count;
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! RadfanCollectionViewCell
        
        cell.backgroundColor = colors[indexPath.row]
        cell.layer.borderColor = colors[indexPath.row].CGColor
        
        return cell;
    }
    
}

// MARK: UICollectionViewDelegate

extension RadfanDemoViewController {
    
}
