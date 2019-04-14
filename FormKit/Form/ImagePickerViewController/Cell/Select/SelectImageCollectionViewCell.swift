//
//  ImagePickerCollectionViewCell.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/11.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit
import Photos

class SelectImageCollectionViewCell: UICollectionViewCell, AssetLoadable {
    
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
    
    override var isSelected: Bool {
        didSet {
            let constant: CGFloat = isSelected ? 3 : 0
            imageViewConstraints.forEach { $0?.constant = constant }
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.contentView.layoutIfNeeded()
            }
        }
    }
    
    var isImageLoaded: Bool {
        return imageView.image != nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addDropShadow(
            offsetSize: CGSize(width: 2, height: 2),
            opacity: 0.6,
            radius: 4.0,
            color: .black
        )
    }
    
    @discardableResult
    func configure(with asset: PHAsset, completion: @escaping (UIImage?) -> Void) -> Self {
        load(asset, completion: completion)
        return self
    }
}
