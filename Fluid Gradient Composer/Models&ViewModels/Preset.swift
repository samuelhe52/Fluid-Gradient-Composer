//
//  Preset.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/8.
//

import Foundation

struct Preset: Codable, Identifiable, Hashable {
    enum BuiltinColor: Codable, CaseIterable, Hashable {
        static let allCases: [Self] = [.blue, .green, .yellow, .orange, .red, .pink, .purple, .teal, .indigo]
        
        case blue, green, yellow, orange, red, pink, purple, teal, indigo
        case custom(String)
    }
    
    var name: String
    var colors: [BuiltinColor]
    var speed: Double
    var highlights: [BuiltinColor]
    
    var id: UUID = UUID()
    
    var locked: Bool = false
    
    mutating func lock() { locked = true }
    
    mutating func unlock() { locked = false }
    
    mutating func randomizeColors() {
        let randomColors = Preset.generateRandomColors()
        colors = randomColors.colors
        highlights = randomColors.highlights
    }
    
    // MARK: - static methods
    
    static let `default`: Self = .init(name: "Default",
                                       colors: defaultColors,
                                       speed: 1,
                                       highlights: defaultColors,
                                       id: .init())
    
    static var blank: Self {
        .init(name: "",
              colors: [],
              speed: 1,
              highlights: [])
    }
    
    static let defaultColors: [BuiltinColor] = [.blue, .green, .yellow, .orange, .red]
    
    static func generateRandomColors(count: Int = 5) -> (colors: [BuiltinColor], highlights: [BuiltinColor]) {
        var colors: [Preset.BuiltinColor] = []
        var highlights: [Preset.BuiltinColor] = []
        let colorPool = Preset.BuiltinColor.allCases
        for _ in 0...(count - 1) {
            colors.append(colorPool.randomElement()!)
        }
        for _ in 0...(count - 1) {
            highlights.append(colorPool.randomElement()!)
        }
        
        return (colors, highlights)
    }
}
