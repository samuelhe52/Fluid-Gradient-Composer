//
//  FluidGradientConfigurationStore.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/8.
//

import Foundation
import SwiftUI

class FluidGradientConfigurationStore: ObservableObject {
    @Published private var configuration: FluidGradientConfiguration {
        didSet { autsave() }
    }
    
    private let autoSaveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Fluid-Gradient-Configuration.json")
    
    private func autsave() {
        save(to: autoSaveURL)
        print("autosaved to \(autoSaveURL)")
    }
    
    private func save(to url: URL) {
        do {
            let configData = try JSONEncoder().encode(configuration)
            try configData.write(to: url)
        } catch {
            print("Error saving configuration to: \(url)")
        }
    }
    
    init(configuration: FluidGradientConfiguration = .init(colors: [], speed: 1, highlights: [])) {
        if let autosavedData = try? Data(contentsOf: autoSaveURL),
           let autosavedConfig = try? JSONDecoder().decode(FluidGradientConfiguration.self, from: autosavedData) {
            self.configuration = autosavedConfig
        } else {
            self.configuration = configuration
            randomizeColors()
        }
    }
    
    var colors: [Color] { configuration.colors.displayColors }
    var highlights: [Color] { configuration.highlights.displayColors }
    var speed: Double {
        get { configuration.speed }
        set { configuration.speed = newValue }
    }
    
    // MARK: - Intents
    func randomizeColors() {
        let randomColors = configuration.generateRandomColors()
        configuration.colors = randomColors.colors
        configuration.highlights = randomColors.highlights
    }
}

extension Array where Element == FluidGradientConfiguration.AvailableColor {
    var displayColors: [Color] { map(\.displayColor) }
}

extension FluidGradientConfiguration.AvailableColor {
    var displayColor: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .orange: return .orange
        case .red: return .red
        case .pink: return .pink
        case .purple: return .purple
        case .teal: return .teal
        case .indigo: return .indigo
        }
    }
}
