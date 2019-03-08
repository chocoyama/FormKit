//
//  ImagePickerFieldCollectionViewCell.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/08.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit

class ImagePickerFieldCollectionViewCell: UICollectionViewCell {
    
    struct Configuration {
        let borderWidth: CGFloat
        let borderColor: UIColor
        let isBlackStyle: Bool
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @discardableResult
    func configure(with configuration: Configuration) -> Self {
        contentView.drawBorder(width: configuration.borderWidth,
                               color: configuration.borderColor)
        
        let imageName = configuration.isBlackStyle ? "camera-black" : "camera-white"
        imageView.image = UIImage(named: imageName, in: .current, compatibleWith: nil)
        return self
    }
    
}
