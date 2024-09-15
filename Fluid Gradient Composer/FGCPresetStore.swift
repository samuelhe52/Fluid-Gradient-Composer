//
//  FluidGradientPresetStore.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/8.
//

import Foundation
import SwiftUI

class FGCPresetStore: ObservableObject {
    @Published private(set) var presets: [FGCPreset] {
        didSet { autosave() }
    }
    
    @Published var currentPresetID: FGCPreset.ID
    private(set) var currentPreset: FGCPreset {
        get {
            presets.filter { $0.id == currentPresetID }.first!
        }
        set {
            if let index = presets.firstIndex(where: { $0.id == currentPresetID }) {
                presets[index] = newValue
            } else {
                print("Error! Could not find preset with ID \(currentPresetID).")
            }
        }
    }
    
    struct FGCSettings: Codable {
        var currentPresetID: FGCPreset.ID
        var presets: [FGCPreset]
        var currentPreset: FGCPreset { presets.filter { $0.id == currentPresetID }.first! }
    }
    
    private let settingsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Fluid-Gradient-Settings.json")
    
    private var autosaveEnabled: Bool = true
    
    private func autosave() {
        if autosaveEnabled {
            save(to: settingsURL)
            print("[\(Date().description)]\nautosaved to \(settingsURL).")
        }
    }
    
    private func save(to url: URL) {
        do {
            let settingsData = try JSONEncoder().encode(
                FGCSettings(currentPresetID: currentPresetID,
                            presets: presets)
            )
            try settingsData.write(to: url)
        } catch {
            print("Error saving settings to: \(url)!")
        }
    }
    
    init() {
        if let existingSettingsData = try? Data(contentsOf: settingsURL),
           let existingSettings = try? JSONDecoder().decode(FGCSettings.self, from: existingSettingsData) {
            self.presets = existingSettings.presets
            self.currentPresetID = existingSettings.currentPreset.id
        } else {
            self.presets = [.default]
            self.currentPresetID = FGCPreset.default.id
        }
    }
    
    var colors: [Color] { currentPreset.colors.displayColors }
    var highlights: [Color] { currentPreset.highlights.displayColors }
    var speed: Double {
        get { currentPreset.speed }
        set { changeSpeed(to: newValue) }
    }
    
    // MARK: - Intents
    func randomizeColors() {
        let randomColors = FGCPreset.generateRandomColors()
        currentPreset.colors = randomColors.colors
        currentPreset.highlights = randomColors.highlights
    }
    
    func modifyPreset(name: String,
                      colors: [FGCPreset.AvailableColor],
                      highlights: [FGCPreset.AvailableColor],
                      speed: Double) {
        currentPreset.name = name
        currentPreset.colors = colors
        currentPreset.highlights = highlights
        currentPreset.speed = speed
    }
    
    func changeSpeed(to speed: Double) {
        currentPreset.speed = speed
    }
    
    func addPreset(withName name: String) {
        var presetName = name
        var counter = 1
        while nameCollision(presetName) {
            presetName = name.appending(" (\(counter))")
            counter += 1
        }
        let preset = FGCPreset(name: presetName,
                               colors: currentPreset.colors,
                               speed: currentPreset.speed,
                               highlights: currentPreset.highlights)
        presets.append(preset)
        currentPresetID = preset.id
        
        func nameCollision(_ name: String) -> Bool {
            presets.map { $0.name }.contains(name)
        }
    }
    
    func deleteCurrentPreset(withID id: FGCPreset.ID) throws {
        guard id != FGCPreset.default.id else { throw FGCStoreError.cannotDeleteDefaultPreset }
        disablingAutoSave {
            presets.removeAll { $0.id == id }
            currentPresetID = presets.first?.id ?? FGCPreset.default.id
        }
    }
    
    /// Disables autosave when the action is taking place, allowing for making two changes and "commit" them once.
    /// Autosave is re-enabled when the action is completed.
    func disablingAutoSave(action: () -> Void) {
        autosaveEnabled = false
        defer {
            autosaveEnabled = true
        }
        action()
    }
}

enum FGCStoreError: Error {
    case cannotDeleteDefaultPreset
}


extension Array where Element == FGCPreset.AvailableColor {
    var displayColors: [Color] { map(\.displayColor) }
}

extension FGCPreset.AvailableColor {
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
