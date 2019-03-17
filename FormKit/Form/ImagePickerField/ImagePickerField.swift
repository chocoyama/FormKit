//
//  ImagePickerField.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/08.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit

public protocol ImagePickerFieldDelegate: class {
    func imagePickerField(_ imagePickerField: ImagePickerField,
                          didSelectAt indexPath: IndexPath,
                          with imagePickerViewController: ImagePickerViewController)
}

public class ImagePickerField: UIView, XibInitializable {
    
    @IBInspectable public var pickCount: Int = 0 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBInspectable public var margin: CGFloat = 8.0
    @IBInspectable public var borderWidth: CGFloat = 1.0
    @IBInspectable public var borderColor: UIColor = UIColor(white: 0.0, alpha: 0.3)
    @IBInspectable public var blackStyle: Bool = false

    @IBOutlet public weak var collectionView: UICollectionView! {
        didSet {
            ImagePickerFieldCollectionViewCell.register(for: collectionView, bundle: .current)
        }
    }
    
    public weak var delegate: ImagePickerFieldDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setXibView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setXibView()
    }
}

extension ImagePickerField: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pickCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return ImagePickerFieldCollectionViewCell
            .dequeue(from: collectionView, indexPath: indexPath)
            .configure(with: .init(borderWidth: borderWidth,
                                   borderColor: borderColor,
                                   isBlackStyle: blackStyle))
    }
}

extension ImagePickerField: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imagePickerViewController = ImagePickerViewController(columnCount: 4, maxSelectCount: 10)
        delegate?.imagePickerField(self, didSelectAt: indexPath, with: imagePickerViewController)
    }
}

extension ImagePickerField: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewHeight = collectionView.frame.size.height
        let width = collectionViewHeight - (margin * 2)
        return CGSize(width: width, height: width)
    }
}
