//
//  RadfanDemoViewController.swift
//  RadfanCollectionView
//
//  Created by Patrick Duvall on 2016-05-01.
//  Copyright © 2016 Patrick Duvall. All rights reserved.
//

import UIKit

class RadfanDemoViewController: UICollectionViewController {
    
    let colors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple]

    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
}

// MARK: UICollectionViewDataSource

extension RadfanDemoViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! RadfanCollectionViewCell
        
        cell.backgroundColor = colors[indexPath.row]
        cell.layer.borderColor = colors[indexPath.row].cgColor
        
        return cell
    }
    
}
