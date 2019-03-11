//
//  SelectedImageCollectionViewCell.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/11.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit

class SelectedImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    @discardableResult
    func configure(with image: UIImage) -> Self {
        imageView.image = image
        return self
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

}
