//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Alec O'Connor on 1/6/18.
//  Copyright © 2018 Alec O'Connor. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    func setImage(with image: UIImage?) {
        
        imageView.image = image
        
        if image != nil {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }

}
