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
    
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var itemImageView: UIImageView!
    
    @discardableResult
    func configure(with configuration: Configuration) -> Self {
        contentView.drawBorder(width: configuration.borderWidth,
                               color: configuration.borderColor)
        showCameraImageView(with: configuration)
        return self
    }
    
    @discardableResult
    func configure(with image: UIImage) -> Self {
        contentView.drawBorder(width: 0.0, color: .clear)
        showItemImageView(with: image)
        return self
    }
    
    private func showCameraImageView(with configuration: Configuration) {
        cameraImageView.isHidden = false
        itemImageView.isHidden = true
        
        let imageName = configuration.isBlackStyle ? "camera-black" : "camera-white"
        cameraImageView.image = UIImage(named: imageName, in: .current, compatibleWith: nil)
    }
    
    private func showItemImageView(with image: UIImage) {
        cameraImageView.isHidden = true
        itemImageView.isHidden = false
        
        itemImageView.image = image
    }
}
