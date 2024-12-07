//
//  Config.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/10/13.
//

import Foundation

struct Config: Codable {
    var version: Version
    
    var presets: [Preset]
    var pinnedPresetIds: Set<Preset.ID>?
    
    init(version: Version = ConfigManager.currentVersion, presets: [Preset], pinnedPresetIds: Set<Preset.ID>? = nil) {
        self.version = version
        self.presets = presets
        self.pinnedPresetIds = pinnedPresetIds
    }
}

extension Config {
    struct Version: Codable, Comparable, CustomStringConvertible, Hashable {
        var major: Int
        var minor: Int
        var patch: Int
        
        var description: String { "\(major).\(minor).\(patch)" }
        
        var dictRepresentation: [String: Any] {
            ["major": major, "minor": minor, "patch": patch]
        }
        
        init?(major: Int, minor: Int, patch: Int) {
            guard major >= 0, minor >= 0, patch >= 0 else {
                return nil
            }
            
            self.major = major
            self.minor = minor
            self.patch = patch
        }
        
        init?(string versionString: String) {
            let splitted = versionString.split(separator: ".")
            if splitted.count != 3 {
                return nil
            }
            guard let major = Int(splitted[0]),
                  let minor = Int(splitted[1]),
                  let patch = Int(splitted[2]) else {
                return nil
            }
            guard major >= 0, minor >= 0, patch >= 0 else {
                return nil
            }
            
            self.major = major
            self.minor = minor
            self.patch = patch
        }
        
        static func < (lhs: Config.Version, rhs: Config.Version) -> Bool {
            return lhs.major < rhs.major ||
            lhs.major == rhs.major && lhs.minor < rhs.minor ||
            lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch
        }
    }
}
