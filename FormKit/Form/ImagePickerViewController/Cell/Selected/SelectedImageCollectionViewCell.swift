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
    
    @discardableResult
    func configure(with image: UIImage) -> Self {
        imageView.image = image
        imageView.backgroundColor = .clear
        return self
    }
    
    @discardableResult
    func configureEmpty() -> Self {
        imageView.image = nil
        imageView.backgroundColor = .white
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
