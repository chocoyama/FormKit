//
//  AlbumViewController.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/17.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit
import Photos

protocol AlbumViewControllerDelegate: class {
    func albumViewController(_ albumViewController: AlbumViewController,
                             didInsertedItemAt indexPath: IndexPath,
                             selectedImages: [UIImage])
    func albumViewController(_ albumViewController: AlbumViewController,
                             didRemovedItemAt indexPath: IndexPath,
                             selectedImages: [UIImage])
}

class AlbumViewController: UIViewController, Pageable {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            SelectImageCollectionViewCell.register(for: collectionView, bundle: .current)
            collectionView.dataSource = self
        }
    }
    
    var pageNumber = 0
    private let repository = PhotoRepository()
    private let columnCount: Int
    
    private var allAssets: PHFetchResult<PHAsset>?
    private let maxSelectCount: Int
    private var selectedImages = [UIImage]()
    
    weak var delegate: AlbumViewControllerDelegate?
    
    init(columnCount: Int, maxSelectCount: Int) {
        self.columnCount = columnCount
        self.maxSelectCount = maxSelectCount
        super.init(nibName: String(describing: AlbumViewController.self), bundle: .current)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allAssets = repository.fetchAllPhotos()
    }

}

extension AlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allAssets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = allAssets?.object(at: indexPath.item) else { fatalError() }
        return SelectImageCollectionViewCell
            .dequeue(from: collectionView, indexPath: indexPath)
            .configure(with: asset)
    }
    
    
}

extension AlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectImageCollectionViewCell,
            let image = cell.imageView.image else { return }
        
        if selectedImages.count >= maxSelectCount && !cell.isSelectedState {
            return
        }
        
        let isSelected = cell.toggleSelectedState()
        if isSelected {
            append(image: image)
        } else {
            remove(image: image, at: indexPath)
        }
    }
    
    func append(image: UIImage) {
        let insertIndexPath = IndexPath(item: selectedImages.count, section: 0)
        
        selectedImages.insert(image, at: insertIndexPath.item)
        
        delegate?.albumViewController(self,
                                      didInsertedItemAt: insertIndexPath,
                                      selectedImages: selectedImages)
    }
    
    private func remove(image: UIImage, at indexPath: IndexPath) {
        let removeIndexPaths = selectedImages
            .enumerated()
            .filter { $0.element == image }
            .map { IndexPath(item: $0.offset, section: 0) }
        
        guard let removeIndexPath = removeIndexPaths.first else { return }
        
        selectedImages.removeAll { $0 == image }
        
        delegate?.albumViewController(self,
                                      didRemovedItemAt: removeIndexPath,
                                      selectedImages: selectedImages)
    }
}

extension AlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
