//
//  ImageSelectedApp.swift
//  ImageSelected
//
//  Created by Thanh Sau on 10/12/2023.
//

import SwiftUI

@main
struct ImageSelectedApp: App {
    
    @StateObject var imageManager: ImageManager = .shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(imageManager)
        }
    }
}
