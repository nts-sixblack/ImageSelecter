//
//  ContentView.swift
//  ImageSelected
//
//  Created by Thanh Sau on 10/12/2023.
//

import SwiftUI
import Photos
import Combine

struct ContentView: View {
    
    @EnvironmentObject var photoLibrary: PhotoLibrary
    
    var body: some View {
        VStack {

//            preview image
            /// 1555 image just using about 35MB
            CollectionView(
                collections: $photoLibrary.photoAssets,
                contentSize: .fixed(.init(width: 120, height: 120)),
                itemSpacing: .init(mainAxisSpacing: 10, crossAxisSpacing: 10),
                onDisplayItem: { item in
                    item.requestPreview()
                },
                onEndDisplayItem: { item in
                    item.removeImage()
                }) { item in
                    PhotoRow(photo: item)
                }
        }
        .onAppear {
            self.photoLibrary.requestAuthorization()
        }
    }
}

struct PhotoRow: View {
    @ObservedObject var photo: Asset
    var body: some View {
        HStack {
            if let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 30)
                    .clipped()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PhotoLibrary())
}
