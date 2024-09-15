//
//  FluidGradientPreset.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/8.
//

import Foundation

struct FGCPreset: Codable, Identifiable{
    enum AvailableColor: Codable, CaseIterable {
        case blue, green, yellow, orange, red, pink, purple, teal, indigo
    }
    
    var name: String
    var colors: [AvailableColor]
    var speed: Double
    var highlights: [AvailableColor]
    
    var id: String { name }
    
    static func generateRandomColors() -> (colors: [AvailableColor], highlights: [AvailableColor]) {
        var colors: [FGCPreset.AvailableColor] = []
        var highlights: [FGCPreset.AvailableColor] = []
        let colorPool = FGCPreset.AvailableColor.allCases
        for _ in 0...Int.random(in: 5...5) {
            colors.append(colorPool.randomElement()!)
        }
        for _ in 0...Int.random(in: 5...5) {
            highlights.append(colorPool.randomElement()!)
        }
        
        return (colors, highlights)
    }
    
    static var `default`: Self = .init(name: "Default",
                                       colors: defaultColors,
                                       speed: 1,
                                       highlights: defaultColors)
    
    static var defaultColors: [AvailableColor] = [.blue, .green, .yellow, .orange, .red]
}
