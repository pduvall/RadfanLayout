//
//  RadfanCollectionViewCell.swift
//  RadfanCollectionView
//
//  Created by Patrick Duvall on 2016-05-01.
//  Copyright © 2016 Patrick Duvall. All rights reserved.
//

import UIKit

class RadfanCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
    }
    
    convenience init () {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupCell()
    }
    
    func setupCell () {
        
        layer.cornerRadius = 10.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 5.0
    }

}
