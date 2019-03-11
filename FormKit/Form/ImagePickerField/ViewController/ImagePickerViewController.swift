//
//  ImagePickerViewController.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/11.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit
import Photos

public class ImagePickerViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            ImagePickerCollectionViewCell.register(for: collectionView, bundle: .current)
        }
    }
    
    private let columnCount: Int
    
    private let repository = PhotoRepository()
    private var allAssets: PHFetchResult<PHAsset>?
    private var selectedValues: [(indexPath: IndexPath, image: UIImage)] = []
    
    init(columnCount: Int) {
        self.columnCount = columnCount
        super.init(nibName: String(describing: ImagePickerViewController.self), bundle: .current)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        allAssets = repository.fetchAllPhotos()
    }

    @IBAction func didTappedDoneBarButtonItem(_ sender: UIBarButtonItem) {
//        let images = selectedValues.map { $0.image }
    }
    
    @IBAction func didTappedCancelBarButtonItem(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension ImagePickerViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allAssets?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = allAssets?.object(at: indexPath.item) else { fatalError() }
        return ImagePickerCollectionViewCell
            .dequeue(from: collectionView, indexPath: indexPath)
            .configure(with: asset)
    }
    
    
}

extension ImagePickerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImagePickerCollectionViewCell,
            let image = cell.imageView.image else { return }
        let isSelected = cell.toggleState()
        if isSelected {
            selectedValues.append((indexPath: indexPath, image: image))
        } else {
            selectedValues.removeAll { $0.indexPath == indexPath }
        }
    }
}

extension ImagePickerViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let columnCount = CGFloat(self.columnCount)
        
        var totalMargin: CGFloat = 0.0
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            totalMargin += flowLayout.minimumInteritemSpacing * (columnCount - 1)
            totalMargin += flowLayout.sectionInset.left + flowLayout.sectionInset.right
        }
        
        let itemWidth = (screenWidth - totalMargin) / columnCount
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
