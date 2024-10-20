//
//  PresetStore.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/8.
//

import Foundation
import SwiftUI
import os
import UniformTypeIdentifiers

extension UTType {
    static let fgcpreset = UTType(exportedAs: "com.samuelhe.fgcpreset")
    static let fgcconfig = UTType(exportedAs: "com.samuelhe.fgcconfig")
}

let logger = Logger(subsystem: "com.samuelhe.fluidgradientcomposer", category: "general")

@Observable
class PresetStore {
    var presets: [Preset] {
        didSet { autosave() }
    }
    private var presetIds: Set<Preset.ID> { Set(presets.map(\.id)) }
    
    private let configURL = URL.documentsDirectory
        .appendingPathComponent("Fluid-Gradient-Config")
        .appendingPathExtension(for: .fgcconfig)
    private var pinnedPresetIds: Set<Preset.ID> = [] {
        didSet { autosave() }
    }
    private var lockedPresetIds: Set<Preset.ID> = [] {
        didSet { autosave() }
    }
    
    func isLocked(presetId id: Preset.ID) -> Bool {
        return lockedPresetIds.contains(id)
    }
    
    var pinnedPresets: [Preset] {
        presets.filter { isPinned(presetId: $0.id) }
    }
    var unpinnedPresets: [Preset] {
        presets.filter { !isPinned(presetId: $0.id) }
    }

    func isPinned(presetId id: Preset.ID) -> Bool {
        return pinnedPresetIds.contains(id)
    }
    
    private var autosaveEnabled: Bool = true
    
    private func autosave() {
        if autosaveEnabled {
            save(to: configURL)
            logger.info("Autosaved to \(self.configURL).")
        }
    }
    
    private func save(to url: URL) {
        do {
            let config = Config(presets: presets, pinnedPresetIds: pinnedPresetIds, lockedPresetIds: lockedPresetIds)
            let configData = try JSONEncoder().encode(config)
            try configData.write(to: url)
        } catch {
            logger.error("Error saving presets to: \(url): \(error.localizedDescription).")
        }
    }
    
    init() {
        if let existingConfigData = try? Data(contentsOf: configURL),
           let config = try? JSONDecoder().decode(Config.self,
                                                  from: existingConfigData)
        {
            self.presets = config.presets
            self.pinnedPresetIds = config.pinnedPresetIds ?? []
            self.lockedPresetIds = config.lockedPresetIds ?? []
        } else {
            self.presets = [.default]
        }
    }
    
    // MARK: - Intents
    func createNewPreset(withName name: String) -> Preset.ID {
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
    }

    func addNewPreset(fromURL url: URL) throws {
        let presetData = try Data(contentsOf: url)
        var preset = try JSONDecoder().decode(Preset.self, from: presetData)
        
        var counter = 1
        while nameCollision(preset.name) {
            preset.name += " (\(counter))"
            counter += 1
        }
        preset.id = UUID() // Create a new UUID for imported presets
        presets.append(preset)
        logger.info("Added preset with name: \"\(preset.name, privacy: .public)\"")
    }
    
    func lock(withPresetId id: Preset.ID) {
        lockedPresetIds.insert(id)
    }
    
    func unlock(withPresetId id: Preset.ID) {
        lockedPresetIds.remove(id)
    }
    
    private func nameCollision(_ name: String) -> Bool {
        presets.map { $0.name }.contains(name)
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
    
    func exportPreset(_ preset: Preset) -> URL? {
        logger.debug("Export preset called: \(preset.name, privacy: .public)")
        do {
            let presetData = try JSONEncoder().encode(preset)
            let url = URL.temporaryDirectory
                .appendingPathComponent(preset.name)
                .appendingPathExtension(for: .fgcpreset)
            try presetData.write(to: url, options: [.atomic])
            return url
        } catch {
            logger.error("Failed to export preset: \(error)")
        }
        return nil
    }
    
    func pin(withPresetId: Preset.ID) {
        if presetIds.contains(withPresetId) {
            pinnedPresetIds.insert(withPresetId)
        } else {
            logger.fault("Preset not found: \(withPresetId)")
        }
        logger.info("Pinned Preset: \(withPresetId)")
    }
    
    func unpin(withPresetId id: Preset.ID) {
        if isPinned(presetId: id) {
            pinnedPresetIds.remove(id)
            logger.info("Unpinned Preset: \(id)")
        } else {
            logger.fault("Preset not found: \(id)")
        }
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


