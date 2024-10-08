//
//  PresetStore.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/8.
//

import Foundation
import SwiftUI
import os

let logger = Logger(subsystem: "com.samuelhe.FluidGradientComposer", category: "general")

@Observable
class PresetStore {
    var presets: [Preset] {
        didSet { autosave() }
    }
    
    private let presetsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Fluid-Gradient-Presets.json")
    
    private var autosaveEnabled: Bool = true
    
    private func autosave() {
        if autosaveEnabled {
            save(to: presetsURL)
            logger.info("Autosaved to \(self.presetsURL).")
        }
    }
    
    private func save(to url: URL) {
        do {
            let settingsData = try JSONEncoder().encode(presets)
            try settingsData.write(to: url)
        } catch {
            logger.error("Error saving presets to: \(url): \(error.localizedDescription).")
        }
    }
    
    init() {
        if let existingPresetsData = try? Data(contentsOf: presetsURL),
           let existingPresets = try? JSONDecoder().decode([Preset].self,
                                                           from: existingPresetsData)
        {
            self.presets = existingPresets
        } else {
            self.presets = [.default]
        }
    }
    
    // MARK: - Intents
    func addNewPreset(withName name: String) -> Preset.ID {
        var presetName = name
        var counter = 1
        while nameCollision(presetName) {
            presetName = name.appending(" (\(counter))")
            counter += 1
        }
        
        let randomColors = Preset.generateRandomColors()
        let preset = Preset(name: presetName,
                               colors: randomColors.colors,
                               speed: 1,
                               highlights: randomColors.highlights)
        presets.append(preset)
        logger.info("Added preset \"\(presetName, privacy: .public)\".")
        
        return preset.id

        func nameCollision(_ name: String) -> Bool {
            presets.map { $0.name }.contains(name)
        }
    }
    
    func deletePreset(at indexSet: IndexSet) throws {
        for index in indexSet {
            guard presets[index].id != Preset.default.id else {
                throw FGCStoreError.cannotDeleteDefaultPreset
            }
        }
        presets.remove(atOffsets: indexSet)
        logger.info("Deleted \(indexSet.count) preset(s).")
    }
    
    func deletePreset(withId id: Preset.ID) throws {
        guard id != Preset.default.id else { throw FGCStoreError.cannotDeleteDefaultPreset }
        disablingAutoSave { presets.removeAll { $0.id == id } }
        logger.info("Deleted preset with ID: \"\(id, privacy: .public)\".")
    }
    
    func movePreset(from source: IndexSet, to destination: Int) {
        presets.move(fromOffsets: source, toOffset: destination)
        logger.info("Moved presets at indexes: \"\(source, privacy: .public)\" to index: \"\(destination, privacy: .public)\".")
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

extension Array where Element == Preset.BuiltinColor {
    var displayColors: [Color] { map(\.displayColor) }
}

extension Preset.BuiltinColor {
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


