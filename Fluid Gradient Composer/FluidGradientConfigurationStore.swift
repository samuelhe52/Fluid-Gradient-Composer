//
//  FluidGradientConfigurationStore.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/8.
//

import Foundation
import SwiftUI

class FluidGradientConfigurationStore: ObservableObject {
    @Published private var configuration: FluidGradientConfiguration
    
    init(configuration: FluidGradientConfiguration = .init(colors: [], speed: 1, highlights: [])) {
        self.configuration = configuration
        randomizeColors()
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
