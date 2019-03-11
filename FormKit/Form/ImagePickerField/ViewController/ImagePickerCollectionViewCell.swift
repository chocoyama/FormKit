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
    
    @IBOutlet weak var imageViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeftConstraint: NSLayoutConstraint!
    private var imageViewConstraints: [NSLayoutConstraint?] {
        return [
            imageViewRightConstraint,
            imageViewLeftConstraint,
            imageViewTopConstraint,
            imageViewBottomConstraint
        ]
    }
    
    private var isSelectedState: Bool = false {
        didSet {
            let constant: CGFloat = isSelectedState ? 3 : 0
            imageViewConstraints.forEach { $0?.constant = constant }
        }
    }
    
    var isImageLoaded: Bool {
        return imageView.image != nil
    }
    
    @discardableResult
    func configure(with asset: PHAsset) -> Self {
        isSelectedState = false
        load(asset)
        return self
    }
    
    func toggleState() -> Bool {
        isSelectedState = !isSelectedState
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.contentView.layoutIfNeeded()
        }
        return isSelectedState
    }
}
