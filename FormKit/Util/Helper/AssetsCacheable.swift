//
//  AssetsCacheable.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/11.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation
import Photos

private var previousPreheatRect: CGRect = .zero

protocol AssetsCacheable {
    var collectionView: UICollectionView { get set }
    var imageManager: PHCachingImageManager { get set }
    var targetSize: CGSize { get set }
    var contentMode: PHImageContentMode { get set }
}

extension AssetsCacheable where Self: UIViewController {
    
    func load(_ asset: PHAsset, to assetLoadable: AssetLoadable) {
        assetLoadable.assetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: nil) { (image, _) in
            if assetLoadable.assetIdentifier == asset.localIdentifier {
                assetLoadable.thumbnailImage = image
            }
        }
    }
    
    func updateCachedAssets(for fetchResult: PHFetchResult<PHAsset>) {
        guard isViewLoaded && view.window != nil else { return }
        
        let preheatRect = view.bounds.insetBy(dx: 0, dy: -0.5 * view.bounds.height)
        
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        
        let addedAssets = getAssets(from: fetchResult, for: addedRects)
        let removedAssets = getAssets(from: fetchResult, for: removedRects)
        
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: targetSize,
                                        contentMode: contentMode,
                                        options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: targetSize,
                                       contentMode: contentMode, options: nil)
        
        previousPreheatRect = preheatRect
    }
    
    private func getAssets(from fetchResult: PHFetchResult<PHAsset>, for rects: [CGRect]) -> [PHAsset] {
        return rects
            .flatMap { collectionView.indexPathsForElements(in: $0) }
            .map { fetchResult.object(at: $0.item) }
    }
    
    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added.append(CGRect(x: new.origin.x,
                                    y: old.maxY,
                                    width: new.width,
                                    height: new.maxY - old.maxY))
            }
            if old.minY > new.minY {
                added.append(CGRect(x: new.origin.x,
                                    y: new.minY,
                                    width: new.width,
                                    height: old.minY - new.minY))
            }
            
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed.append(CGRect(x: new.origin.x,
                                      y: new.maxY,
                                      width: new.width,
                                      height: old.maxY - new.maxY))
            }
            if old.minY < new.minY {
                removed.append(CGRect(x: new.origin.x,
                                      y: old.minY,
                                      width: new.width,
                                      height: new.minY - old.minY))
            }
            
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}
