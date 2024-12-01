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
    
    static let configURL = URL.documentsDirectory
        .appendingPathComponent("FGCConfig")
        .appendingPathExtension(for: .fgcconfig)
    private var pinnedPresetIds: Set<Preset.ID> = [] {
        didSet { autosave() }
    }
    
    // MARK: - Pinning
    var pinnedPresets: [Preset] {
        presets.filter { isPinned(presetId: $0.id) }
    }
    var unpinnedPresets: [Preset] {
        presets.filter { !isPinned(presetId: $0.id) }
    }

    func isPinned(presetId id: Preset.ID) -> Bool {
        return pinnedPresetIds.contains(id)
    }
    
    // MARK: - Saving config
    private var autosaveEnabled: Bool = true
    
    private func autosave() {
        if autosaveEnabled {
            let config = Config(presets: presets, pinnedPresetIds: pinnedPresetIds)
            ConfigManager.save(config, to: Self.configURL)
            logger.info("Autosaved to \(PresetStore.configURL).")
        }
    }
    
    /// Disables autosave when the action is taking place, allowing for making two changes and "commit" them once.
    /// Autosave is re-enabled when the action is completed.
    private func disablingAutoSave(action: () -> Void) {
        autosaveEnabled = false
        defer {
            autosaveEnabled = true
            autosave() // "Commit" the changes after the actions completed
        }
        action()
    }
    
    // MARK: - Init
    init() {
        do {
            let url = Self.configURL
            if !FileManager.default.fileExists(atPath: url.path()) {
                FileManager.default.createFile(atPath: url.path(),
                                               contents: nil,
                                               attributes: nil)
            }
            let config = try ConfigManager.decodeConfig(fromURL: url)
            self.presets = config.presets
            self.pinnedPresetIds = config.pinnedPresetIds ?? []
            ConfigManager.save(config, to: Self.configURL)
        } catch {
            logger.error("Error reading config file: \(error.localizedDescription)")
            self.presets = [.default]
        }
    }
    
    private func loadConfig() {
        if let config = try? ConfigManager.decodeConfig(fromURL: Self.configURL)
        {
            self.presets = config.presets
            self.pinnedPresetIds = config.pinnedPresetIds ?? []
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
    
    private func nameCollision(_ name: String) -> Bool {
        presets.map { $0.name }.contains(name)
    }
    
    func deletePreset(at indexSet: IndexSet) throws {
        for index in indexSet {
            guard presets[index].id != Preset.default.id else {
                throw PresetStoreError.cannotDeleteDefaultPreset
            }
        }
        presets.remove(atOffsets: indexSet)
        logger.info("Deleted \(indexSet.count) preset(s).")
    }
    
    func deletePreset(withId id: Preset.ID) throws {
        guard id != Preset.default.id else { throw PresetStoreError.cannotDeleteDefaultPreset }
        disablingAutoSave { presets.removeAll { $0.id == id } }
        logger.info("Deleted preset with ID: \"\(id, privacy: .public)\".")
    }
    
    func movePreset(from source: IndexSet, to destination: Int) {
        presets.move(fromOffsets: source, toOffset: destination)
        logger.info("Moved presets at indexes: \"\(source, privacy: .public)\" to index: \"\(destination, privacy: .public)\".")
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
    
    // MARK: - Applying config
    func applyNewConfig(fromURL url: URL) throws {
        let config = try ConfigManager.decodeConfig(fromURL: url)
        try applyNewConfig(config)
    }
    
    func applyNewConfig(_ config: Config) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let configData = try encoder.encode(config)
        try configData.write(to: PresetStore.configURL)
        loadConfig()
    }
}

enum PresetStoreError: LocalizedError {
    case cannotDeleteDefaultPreset
    case fileImportError(Error)
    case missingConfig
    case configManagerError(ConfigManagerError)
    // Use this very carefully!!!
    case other(Error)
    
    var errorDescription: String? {
        switch self {
        case .cannotDeleteDefaultPreset: return "Cannot delete the default preset."
        case .fileImportError(let error): return "Error opening file: \(error.localizedDescription)"
        case .other(let error): return "Other error: \(error.localizedDescription)"
        case .missingConfig: return "Missing configuration file."
        case .configManagerError(let error): return "\(error.localizedDescription)"
        }
    }
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
        case .custom(let hex): return Color(hex: hex) ?? .clear
        }
    }
}


