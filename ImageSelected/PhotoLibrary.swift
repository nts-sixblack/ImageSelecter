//
//  PhotoLibrary.swift
//  ImageSelected
//
//  Created by Thanh Sau on 21/01/2024.
//

import Foundation
import SwiftUI
import Combine
import Photos

class Asset: ObservableObject, Identifiable {
    
//    static func == (lhs: Asset, rhs: Asset) -> Bool {
//        lhs.id == rhs.id
//    }
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
    
    @Published var image: UIImage? = nil
    
    let asset: PHAsset
    
    private var manager = PHImageManager.default()
    func requestPreview() {
        DispatchQueue.main.async {
            
            if let image = ImageCache.shared.get(forKey: self.asset.localIdentifier) {
                self.image = image
            } else {
                self.manager.requestImage(for: self.asset, targetSize: CGSize(width: 120, height: 120), contentMode: .aspectFit, options: nil) { [weak self] (image, info) in
                    self?.image = image
                }
            }
        }
    }
    
    func removeImage() {
        self.image = nil
    }
    
    init(asset: PHAsset) {
        self.asset = asset
    }
}

class PhotoLibrary: ObservableObject {
    
    @Published var photoAssets = [Asset]()
    
    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            guard let self = self else { return }
            
            switch status {
            case .authorized:
                self.getAllPhotos()
            case .denied:
                break
            case .notDetermined:
                break
            case .restricted:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func getAllPhotos() {
        let assets: PHFetchResult = PHAsset.fetchAssets(with: .image, options: nil)
        var _photoAssets = [Asset]()
        
        assets.enumerateObjects { (asset, index, stop) in
            autoreleasepool {
                PHCachingImageManager.default().requestImage(for: asset, targetSize: .init(width: 120, height: 120), contentMode: .aspectFill, options: nil) { _, _ in
                }
                _photoAssets.append(Asset(asset: asset))
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.photoAssets = _photoAssets
        }
        
    }
}

extension PHAsset: Identifiable {
}
