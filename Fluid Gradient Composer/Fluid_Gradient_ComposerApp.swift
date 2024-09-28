//
//  Fluid_Gradient_ComposerApp.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/8.
//

import SwiftUI

@main
struct Fluid_Gradient_ComposerApp: App {
    @State var presetStore: PresetStore = .init()
    
    var body: some Scene {
        WindowGroup {
            PresetManagerView(store: presetStore)
        }
    }
}
