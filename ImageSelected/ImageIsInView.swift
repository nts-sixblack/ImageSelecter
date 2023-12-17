//
//  ImageIsInView.swift
//  ImageSelected
//
//  Created by Thanh Sau on 10/12/2023.
//

import Foundation
import SwiftUI
import URLImage
import Photos

struct ImageIsInView: View {
    
    @EnvironmentObject var imageManager: ImageManager
    
    @State var visibleIndex: Set<Int> = [0]
    @State var currentSelected: Int = 0
       
    var body: some View {
        VStack {
            Text(visibleIndex.map( { $0.description }).sorted().joined(separator: ", "))
            
            Text("currenct Selected: \(currentSelected)")
            // The outer GeometryReader has to go directly around your ScrollView
            GeometryReader { outerProxy in
                ScrollViewReader { scrollProxy in
                    
                    Button(action: {
                        withAnimation {
                            scrollProxy.scrollTo(3)
                        }
                    }, label: {
                        Text("Scroll to 3")
                    })
                    
                    Text("\(imageManager.assetsCollection.count)")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(alignment: .top) {
                            
                            ForEach(imageManager.assetsCollection.indices, id: \.self) { index in
                                LocalImageView(currentSelected: $currentSelected, index: index, item: imageManager.assetsCollection[index], geometryProxy: outerProxy, scrollProxy: scrollProxy)
                            }                        
                        //  ForEach(0..<1000, id: \.self) { item in
                        //      ItemView(currentSelected: $currentSelected, item: item, geometryProxy: outerProxy, scrollProxy: scrollReader)
                        //  }
                        }
                    }
                    .scrollDisabled(true)
                    .coordinateSpace(name: "scrollView")
                }
            }
        }
        .onAppear {
            imageManager.requestPhotoAccessPermission()
        }
    }
    
    private func isInView(innerRect:CGRect, isIn outerProxy:GeometryProxy) -> Bool {
        let innerOrigin = innerRect.origin.x
        let imageWidth = innerRect.width
        let scrollOrigin = outerProxy.frame(in: .global).origin.x
        let scrollWidth = outerProxy.size.width
        if innerOrigin + imageWidth < scrollOrigin + scrollWidth && innerOrigin + imageWidth > scrollOrigin ||
            innerOrigin + imageWidth > scrollOrigin && innerOrigin < scrollOrigin + scrollWidth {
            return true
        }
        return false
    }
}

struct ItemView: View {
    
    @Binding var currentSelected: Int
    var item: Int
    var geometryProxy: GeometryProxy
    var scrollProxy: ScrollViewProxy
    
    @State private var offset: CGSize = .zero
    
    let url: URL = URL(string: "https://dfstudio-d420.kxcdn.com/wordpress/wp-content/uploads/2019/06/digital_camera_photo-1080x675.jpg")!
    
    var body: some View {
        GeometryReader { geometry in
//            Rectangle()
            RemoteImage(url: "https://dfstudio-d420.kxcdn.com/wordpress/wp-content/uploads/2019/06/digital_camera_photo-1080x675.jpg")
                .cornerRadius(13)
                .overlay(
                    Text("Item: \(item)")
                )
                // every time the ScrollView moves, the inner geometry changes and is
                // picked up here:
                .onChange(of: geometry.frame(in: .named("scrollView"))) { imageRect in
                    if isInView(innerRect: imageRect, isIn: geometryProxy) {
//                        visibleIndex.insert(item)
                        currentSelected = item
                    } else {
//                        visibleIndex.remove(item)
                    }
                }
        }
        .padding(.horizontal)
        .frame(width: UIScreen.main.bounds.width)
        .id(item)
        .offset(offset)
        .gesture(
            DragGesture()
                .onChanged({ value in
//                    self.offset = value.translation
                    self.offset.width = value.translation.width
//                    self.offset.height = value.translation.height
                })
                .onEnded({ value in
                    if value.translation.width > 0 {
                        withAnimation {
                            scrollProxy.scrollTo(item-1)
                        }
                    } else {
                        withAnimation {
                            scrollProxy.scrollTo(item+1)
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        withAnimation {
                            self.offset = .zero
                        }
                    })
                    
                })
        )
    }
    
    private func isInView(innerRect:CGRect, isIn outerProxy:GeometryProxy) -> Bool {
        let innerOrigin = innerRect.origin.x
        let imageWidth = innerRect.width
        let scrollOrigin = outerProxy.frame(in: .global).origin.x
        let scrollWidth = outerProxy.size.width
        if innerOrigin + imageWidth < scrollOrigin + scrollWidth && innerOrigin + imageWidth > scrollOrigin ||
            innerOrigin + imageWidth > scrollOrigin && innerOrigin < scrollOrigin + scrollWidth {
            return true
        }
        return false
    }
}

struct LocalImageView: View {
    
    @Binding var currentSelected: Int
    var index: Int
    var item: PHAsset
    var geometryProxy: GeometryProxy
    var scrollProxy: ScrollViewProxy
    
    @State private var offset: CGSize = .zero
    @State private var uiImage = UIImage()
    
    var body: some View {
        GeometryReader { geometry in
//            Rectangle()
//            Image(uiImage: item)
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .cornerRadius(13)
//                .overlay(
//                    Text("Item: \(item)")
//                )
                // every time the ScrollView moves, the inner geometry changes and is
                // picked up here:
                .onChange(of: geometry.frame(in: .named("scrollView"))) { imageRect in
                    if isInView(innerRect: imageRect, isIn: geometryProxy) {
//                        visibleIndex.insert(item)
                        currentSelected = index
                    } else {
//                        visibleIndex.remove(item)
                    }
                }
        }
        .padding(.horizontal)
        .frame(width: UIScreen.main.bounds.width)
        .id(item)
        .offset(offset)
        .gesture(
            DragGesture()
                .onChanged({ value in
//                    self.offset = value.translation
                    self.offset.width = value.translation.width
//                    self.offset.height = value.translation.height
                })
                .onEnded({ value in
                    if value.translation.width > 0 {
                        withAnimation {
                            scrollProxy.scrollTo(index-1)
                        }
                    } else {
                        withAnimation {
                            scrollProxy.scrollTo(index+1)
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        withAnimation {
                            self.offset = .zero
                        }
                    })
                    
                })
        )
        .onAppear {
            self.getUIImageFromAsset(item)
        }
        .onDisappear {
            self.uiImage = UIImage()
        }
    }
    
    private func isInView(innerRect:CGRect, isIn outerProxy:GeometryProxy) -> Bool {
        let innerOrigin = innerRect.origin.x
        let imageWidth = innerRect.width
        let scrollOrigin = outerProxy.frame(in: .global).origin.x
        let scrollWidth = outerProxy.size.width
        if innerOrigin + imageWidth < scrollOrigin + scrollWidth && innerOrigin + imageWidth > scrollOrigin ||
            innerOrigin + imageWidth > scrollOrigin && innerOrigin < scrollOrigin + scrollWidth {
            return true
        }
        return false
    }
    
    private func getUIImageFromAsset(_ asset: PHAsset) {
        
//        PHCachingImageManager.default().requestImage(for: asset, targetSize: .init(width: 100, height: 100), contentMode: .aspectFill, options: nil) { image, _ in
//            self.uiImage = image ?? UIImage()
//        }
        
        if let cachedImage = ImageCache.shared.get(forKey: asset.localIdentifier) {
            self.uiImage = cachedImage
            return
        }
        
        let _manager = PHImageManager.default()
        let _requestOptions = PHImageRequestOptions()
        
        _requestOptions.resizeMode = .fast
        _requestOptions.isSynchronous = true
        
        _manager.requestImageDataAndOrientation(for: asset, options: nil) { (data, _, _, _) in
            guard let _data = data else { return }
            autoreleasepool {
                DispatchQueue.main.async {
                    let uiImage = UIImage(data: _data) ?? UIImage()
                    
                    ImageCache.shared.set(uiImage, forKey: asset.localIdentifier)
                    self.uiImage = uiImage
                }
            }
        }
    }
}

#Preview {
    ImageIsInView()
}
