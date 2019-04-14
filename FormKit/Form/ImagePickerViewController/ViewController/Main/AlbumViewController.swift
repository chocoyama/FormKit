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
                             selectedImages: [PickedImage])
    func albumViewController(_ albumViewController: AlbumViewController,
                             didRemovedItemAt indexPath: IndexPath,
                             selectedImages: [PickedImage])
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
    private var pickedImages = [PickedImage]()
    
    weak var delegate: AlbumViewControllerDelegate?
    
    init(columnCount: Int, maxSelectCount: Int, pickedImages: [PickedImage]) {
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
        let hasPicked = pickedImages.compactMap { $0.albumIndexPath }.contains(indexPath)
        if hasPicked {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        return SelectImageCollectionViewCell
            .dequeue(from: collectionView, indexPath: indexPath)
            .configure(with: asset)
    }
    
}

extension AlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return pickedImages.count <= maxSelectCount - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectImageCollectionViewCell,
            let image = cell.imageView.image else { return }
        append(pickedImage: PickedImage(image: image,
                                        albumIndexPath: indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectImageCollectionViewCell,
            let image = cell.imageView.image else { return }
        remove(pickedImage: PickedImage(image: image,
                                        albumIndexPath: indexPath))
    }
    
    func append(pickedImage: PickedImage) {
        let insertIndexPath = IndexPath(item: pickedImages.count, section: 0)
        
        pickedImages.insert(pickedImage, at: insertIndexPath.item)
        
        delegate?.albumViewController(self,
                                      didInsertedItemAt: insertIndexPath,
                                      selectedImages: pickedImages)
    }
    
    func remove(pickedImage: PickedImage) {
        let removeIndexPaths = pickedImages
            .enumerated()
            .filter { $0.element.albumIndexPath == pickedImage.albumIndexPath }
            .map { IndexPath(item: $0.offset, section: 0) }
        
        guard let removeIndexPath = removeIndexPaths.first else { return }
        
        pickedImages.removeAll { $0.albumIndexPath == pickedImage.albumIndexPath }
        
        if let albumIndexPath = pickedImage.albumIndexPath,
            collectionView.indexPathsForSelectedItems?.contains(albumIndexPath) == true {
            collectionView.deselectItem(at: albumIndexPath, animated: true)
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
        reload(for: changeDetails)
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
