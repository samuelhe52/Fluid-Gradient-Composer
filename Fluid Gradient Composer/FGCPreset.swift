//
//  FluidGradientPreset.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/8.
//

import Foundation

struct FGCPreset: Codable, Identifiable {
    enum BuiltinColor: Codable, CaseIterable {
        case blue, green, yellow, orange, red, pink, purple, teal, indigo
    }
    
    var name: String
    var colors: [BuiltinColor]
    var speed: Double
    var highlights: [BuiltinColor]
    
    var id: UUID = UUID()
    
    mutating func randomizeColors() {
        let randomColors = FGCPreset.generateRandomColors()
        colors = randomColors.colors
        highlights = randomColors.highlights
    }
    
    // MARK: - static methods
    
    static let `default`: Self = .init(name: "Default",
                                       colors: defaultColors,
                                       speed: 1,
                                       highlights: defaultColors,
                                       id: .init(uuidString: "9A2F1A9E-4579-4B79-A99E-6477FF635A09") ?? .init())
    
    static let defaultColors: [BuiltinColor] = [.blue, .green, .yellow, .orange, .red]
    
    static func generateRandomColors() -> (colors: [BuiltinColor], highlights: [BuiltinColor]) {
        var colors: [FGCPreset.BuiltinColor] = []
        var highlights: [FGCPreset.BuiltinColor] = []
        let colorPool = FGCPreset.BuiltinColor.allCases
        for _ in 0...Int.random(in: 5...5) {
            colors.append(colorPool.randomElement()!)
        }
        for _ in 0...Int.random(in: 5...5) {
            highlights.append(colorPool.randomElement()!)
        }
        
        return (colors, highlights)
    }
}
