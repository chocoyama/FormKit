//
//  ImagePickerCollectionViewCell.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/11.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit
import Photos

class ImagePickerCollectionViewCell: UICollectionViewCell, AssetLoadable {
    
    let imageManager = PHImageManager()
    let imageContentMode: PHImageContentMode = .aspectFill
    
    var assetIdentifier: String?
    var thumbnailImage: UIImage? {
        didSet {
            imageView.image = thumbnailImage
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    
    @discardableResult
    func configure(with asset: PHAsset) -> Self {
        load(asset)
        return self
    }
}
