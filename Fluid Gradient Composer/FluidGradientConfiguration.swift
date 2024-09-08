//
//  FluidGradientConfiguration.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/8.
//

import Foundation

struct FluidGradientConfiguration: Codable, Identifiable {
    enum AvailableColor: Codable, CaseIterable {
        case blue, green, yellow, orange, red, pink, purple, teal, indigo
    }
    
    var colors: [AvailableColor]
    var speed: Double
    var highlights: [AvailableColor]
    
    var id: UUID = UUID()
    
    func generateRandomColors() -> (colors: [AvailableColor], highlights: [AvailableColor]) {
        var colors: [FluidGradientConfiguration.AvailableColor] = []
        var highlights: [FluidGradientConfiguration.AvailableColor] = []
        let colorPool = FluidGradientConfiguration.AvailableColor.allCases
        for _ in 0...Int.random(in: 5...5) {
            colors.append(colorPool.randomElement()!)
        }
        for _ in 0...Int.random(in: 5...5) {
            highlights.append(colorPool.randomElement()!)
        }
        
        return (colors, highlights)
    }
}
