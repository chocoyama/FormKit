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
            collectionView.allowsMultipleSelection = true
        }
    }
    
    var pageNumber = 0
    private let repository = PhotoRepository()
    private let columnCount: Int
    
    private var allAssets: PHFetchResult<PHAsset>?
    private let maxSelectCount: Int
    private var pickedImages = [UIImage]()
    
    weak var delegate: AlbumViewControllerDelegate?
    
    init(columnCount: Int, maxSelectCount: Int, pickedImages: [UIImage]) {
        self.columnCount = columnCount
        self.maxSelectCount = maxSelectCount
        self.pickedImages = pickedImages
        super.init(nibName: String(describing: AlbumViewController.self), bundle: .current)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repository.register(observer: self)
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
            .configure(with: asset, completion: { [weak self] image in
                guard let self = self, let image = image else { return }
                let hasPicked = self.pickedImages.contains(where: { $0.isEqualData(image) })
                if hasPicked {
                    self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                } else {
                    self.collectionView.deselectItem(at: indexPath, animated: false)
                }
            })
    }
    
}

extension AlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return pickedImages.count <= maxSelectCount - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectImageCollectionViewCell,
            let image = cell.imageView.image else { return }
        append(pickedImage: image)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectImageCollectionViewCell,
            let image = cell.imageView.image else { return }
        remove(pickedImage: image)
    }
    
    func append(pickedImage: UIImage) {
        let insertIndexPath = IndexPath(item: pickedImages.count, section: 0)
        
        pickedImages.insert(pickedImage, at: insertIndexPath.item)
        
        delegate?.albumViewController(self,
                                      didInsertedItemAt: insertIndexPath,
                                      selectedImages: pickedImages)
    }
    
    func remove(pickedImage: UIImage) {
        let removeIndexPaths = pickedImages
            .enumerated()
            .filter { $0.element.isEqualData(pickedImage) }
            .map { IndexPath(item: $0.offset, section: 0) }
        
        guard let removeIndexPath = removeIndexPaths.first else { return }
        
        pickedImages.removeAll { $0.isEqualData(pickedImage) }
        
        let indexPath = collectionView.indexPathsForVisibleItems
            .enumerated()
            .first(where: { (offset, element) -> Bool in
                let cell = collectionView.cellForItem(at: element) as? SelectImageCollectionViewCell
                let image = cell?.imageView.image
                return image?.isEqualData(pickedImage) == true
            })?
            .element
        if let indexPath = indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        
        delegate?.albumViewController(self,
                                      didRemovedItemAt: removeIndexPath,
                                      selectedImages: pickedImages)
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

extension AlbumViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchedResult = allAssets,
            let changeDetails = changeInstance.changeDetails(for: fetchedResult) else { return }
        allAssets = changeDetails.fetchResultAfterChanges
        reload()
    }
    
    private func reload() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func reload(for changeDetails: PHFetchResultChangeDetails<PHAsset>) {
        DispatchQueue.main.async {
            self.collectionView.performBatchUpdates({
                if let removedIndexes = changeDetails.removedIndexes, !removedIndexes.isEmpty {
                    let removedIndexPaths = removedIndexes.map { IndexPath(item: $0, section: 0) }
                    self.collectionView.deleteItems(at: removedIndexPaths)
                }
                if let insertedIndexes = changeDetails.insertedIndexes, !insertedIndexes.isEmpty {
                    let insertIndexPaths = insertedIndexes.map { IndexPath(item: $0, section: 0) }
                    self.collectionView.insertItems(at: insertIndexPaths)
                }
                if let changedIndexes = changeDetails.changedIndexes, !changedIndexes.isEmpty {
                    let changedIndexPaths = changedIndexes.map { IndexPath(item: $0, section: 0) }
                    self.collectionView.reloadItems(at: changedIndexPaths)
                }
            }) { (finshed) in
            }
        }
    }
}

extension UIImage {
    func isEqualData(_ image: UIImage) -> Bool {
        if !image.size.equalTo(self.size) {
            return false
        }
        
        if let dataProvider1 = self.cgImage?.dataProvider,
            let dataProvider2 = image.cgImage?.dataProvider {
            if let data1 = dataProvider1.data,
                let data2 = dataProvider2.data {
                return data1 == data2
            }
        }
        return false
    }
}
