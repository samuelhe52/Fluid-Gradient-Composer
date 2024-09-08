//
//  Fluid_Gradient_ComposerApp.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/8.
//

import SwiftUI

@main
struct Fluid_Gradient_ComposerApp: App {
    @AppStorage("ColorSchemeMode") private var colorSchemeMode: ColorSchemeMode = .system
    @Environment(\.colorScheme) private var systemColorScheme
    var colorScheme: ColorScheme {
        switch colorSchemeMode {
        case .light: .light
        case .dark: .dark
        case .system: systemColorScheme
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(configurationStore: .init())
                .preferredColorScheme(colorScheme)
        }
    }
}
