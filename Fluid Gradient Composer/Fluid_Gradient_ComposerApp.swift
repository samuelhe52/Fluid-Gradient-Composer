//
//  Fluid_Gradient_ComposerApp.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/8.
//

import SwiftUI
import os

let logger = Logger(subsystem: "com.samuelhe.fluidgradientcomposer", category: "general")

@main
struct Fluid_Gradient_ComposerApp: App {
    @State var presetStore: PresetStore = .init()
    @State var coordinator: FullScreenPreviewCoordinator = .shared
    
    @AppStorage("ColorSchemeMode") private var colorSchemeMode: ColorSchemeMode = .system
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some Scene {
        WindowGroup {
            PresetManager(store: presetStore)
                .preferredColorScheme(getColorScheme())
                .navigationTitle("Preset Manager")
        }
        
        WindowGroup("FullScreenPreview", for: Preset.ID.self) { $presetId in
            FullScreenPreview(coordinator: coordinator)
                .onAppear { coordinator.presentingPresetId = presetId }
                .preferredColorScheme(getColorScheme())
                .environment(presetStore)
        }
    }
    
    private func getColorScheme() -> ColorScheme {
        switch colorSchemeMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return systemColorScheme
        }
    }
}
