//
//  PhotoRepository.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/08.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation
import Photos

public class PhotoRepository {
    
    private var allPhotoOptions: PHFetchOptions {
        let allPhotoOptions = PHFetchOptions()
        allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return allPhotoOptions
    }
    
    public func authorization(handler: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization(handler)
    }
    
    public func register(observer: PHPhotoLibraryChangeObserver) {
        PHPhotoLibrary.shared().register(observer)
    }
    
    public func unregister(observer: PHPhotoLibraryChangeObserver) {
        PHPhotoLibrary.shared().unregisterChangeObserver(observer)
    }
    
    public func fetchAllPhotos() -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(with: allPhotoOptions)
    }
    
}

extension PhotoRepository {
    private func openSetting() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
