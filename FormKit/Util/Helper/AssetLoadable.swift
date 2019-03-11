//
//  AssetLoadable.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/11.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation
import Photos

public protocol AssetLoadable: class {
    var imageManager: PHImageManager { get }
    var imageContentMode: PHImageContentMode { get }
    var assetIdentifier: String? { get set }
    var thumbnailImage: UIImage? { get set }
}

extension AssetLoadable where Self: UICollectionViewCell {
    public func thumbnailSize(for cellSize: CGSize) -> CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: cellSize.width * scale,
                      height: cellSize.height * scale)
    }
    
    func load(_ asset: PHAsset) {
        self.assetIdentifier = asset.localIdentifier
        let targetSize = thumbnailSize(for: self.bounds.size)
        imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: imageContentMode,
            options: nil
        ) { (image, _) in
            if self.assetIdentifier == asset.localIdentifier {
                self.thumbnailImage = image
            }
        }
    }
}
