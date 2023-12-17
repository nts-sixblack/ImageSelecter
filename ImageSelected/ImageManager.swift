//
//  ImageManager.swift
//  ImageSelected
//
//  Created by Thanh Sau on 10/12/2023.
//

import Foundation
import UIKit
import Photos

class ImageManager: ObservableObject {
    static var shared: ImageManager = .init()
    
    private init() {}
    
    @Published var fetchedImages: [UIImage?] = []
    @Published var assetsCollection: [PHAsset] = []
    
    var fetch: PHFetchResult<PHAsset>?
    
    var _manager = PHImageManager.default()
    
    func requestPhotoAccessPermission() {
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            if status == .authorized || status == .limited {
                self?.fetchImages()
            }
        }
    }
    
    public func fetchImages() {
        let _options = PHFetchOptions()
        _options.includeHiddenAssets = false
        _options.includeAssetSourceTypes = [.typeUserLibrary]
        _options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        _options.fetchLimit = 14
        
        self.fetch = PHAsset.fetchAssets(with: .image, options: _options)
        
        self.fetch?.enumerateObjects({ asset, _, _ in
            self.assetsCollection.append(asset)
            PHCachingImageManager.default().requestImage(for: asset, targetSize: .init(width: 100, height: 100), contentMode: .aspectFill, options: nil) { _, _ in }
        })
    }
}

extension Optional {
    var isNil: Bool {
        guard case Optional.none = self else {
            return false
        }
        return true
    }

    var isSome: Bool {
        return !self.isNil
    }
}
