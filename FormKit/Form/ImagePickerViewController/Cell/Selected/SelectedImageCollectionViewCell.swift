//
//  SelectedImageCollectionViewCell.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/11.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit

protocol SelectedImageCollectionViewCellDelegate: class {
    func selectedImageCollectionViewCell(_ cell: SelectedImageCollectionViewCell,
                                         didTappedDeleteButton button: UIButton,
                                         with image: UIImage?)
}

class SelectedImageCollectionViewCell: UICollectionViewCell {

    weak var delegate: SelectedImageCollectionViewCellDelegate?
    
    @IBOutlet weak var deleteButton: UIButton!
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
    func configure(with image: UIImage,
                   canDelete: Bool,
                   delegate: SelectedImageCollectionViewCellDelegate) -> Self {
        imageView.image = image
        imageView.backgroundColor = .clear
        deleteButton.isHidden = !canDelete
        self.delegate = delegate
        return self
    }
    
    @discardableResult
    func configureEmpty() -> Self {
        imageView.image = nil
        imageView.backgroundColor = .white
        deleteButton.isHidden = true
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

    @IBAction func didTappedDeleteButton(_ sender: UIButton) {
        delegate?.selectedImageCollectionViewCell(self,
                                                  didTappedDeleteButton: sender,
                                                  with: imageView.image)
    }
}
