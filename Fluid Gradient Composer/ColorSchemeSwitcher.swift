//
//  ColorSchemeSwitcher.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/8.
//

import SwiftUI

enum ColorSchemeMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

struct ColorSchemeSwitcher: View {
    @AppStorage("ColorSchemeMode") private var colorSchemeMode: ColorSchemeMode = .system
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some View {
        Menu {
            ForEach(ColorSchemeMode.allCases, id: \.self) { mode in
                Button(mode.rawValue) {
                    colorSchemeMode = mode
                    applyColorScheme()
                }
            }
        } label: {
            Text(colorSchemeMode.rawValue)
        }
        .onChange(of: systemColorScheme) { _ in
            if colorSchemeMode == .system {
                applyColorScheme()
            }
        } // Update the view when system preferred scheme changes
    }
    
    private func applyColorScheme() {
        #if os(iOS)
        UIApplication.shared.connectedScenes.forEach { scene in
            if let windowScene = scene as? UIWindowScene,
               let window = windowScene.windows.first {
                UIView.transition(with: window,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    switch colorSchemeMode {
                    case .light:
                        window.overrideUserInterfaceStyle = .light
                    case .dark:
                        window.overrideUserInterfaceStyle = .dark
                    case .system:
                        window.overrideUserInterfaceStyle = .unspecified
                    }
                }, completion: nil)
            }
        }
        #endif
        #if os(macOS)
        let newAppearance: NSAppearance?
        switch colorSchemeMode {
        case .light:
            newAppearance = NSAppearance(named: .aqua)
        case .dark:
            newAppearance = NSAppearance(named: .darkAqua)
        case .system:
            newAppearance = nil
        }
        
        NSApp.appearance = newAppearance
        #endif
    }
}