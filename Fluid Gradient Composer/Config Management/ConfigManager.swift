//
//  ConfigManager.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/12/1.
//

import Foundation

class ConfigManager {
    static let currentVersion: Config.Version = .init(string: "0.1.0")!
    
    static func decodeConfig(from data: Data) throws -> Config {
        if let config = try? JSONDecoder().decode(Config.self,
                                                  from: data) {
            return config
        } else {
            if let configDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                var mutableConfigDict = configDict
                if mutableConfigDict["version"] == nil ||
                    Self.dictToVersion(mutableConfigDict["version"] as? [String: Any] ?? [:]) == nil {
                    logger.warning("No version number found. Trying to enforce current version.")
                    mutableConfigDict["version"] = Self.currentVersion.dictRepresentation
                    let configData = try JSONSerialization.data(withJSONObject: mutableConfigDict)
                    let config = try decodeConfig(from: configData)
                    return config
                } else {
                    logger.warning("Version number found is incompatible. Trying to migrate.")
                    let config = try migrateConfig(configDict: configDict)
                    return config
                }
            } else {
                throw ConfigManagerError.cannotDecodeConfig
            }
        }
    }
        
    private static func migrateConfig(configDict: [String: Any]) throws -> Config {
        if let version = Self.dictToVersion(
            configDict["version"] as? [String: Any] ?? [:]
        ) {
            guard version < Self.currentVersion,
                  ConfigMigration.compatibleVersions.contains(version) else {
                throw ConfigManagerError.incompatibleVersion
            }
            let migrated = try ConfigMigration.migrate(configDict: configDict, version: version)
            return migrated
        } else {
            throw ConfigManagerError.cannotDecodeConfig
        }
    }
    
    private static func versionToDict(_ version: Config.Version) -> [String: Any] {
        ["major": version.major, "minor": version.minor, "patch": version.patch]
    }
    private static func dictToVersion(_ dict: [String: Any]) -> Config.Version? {
        guard let major = dict["major"] as? Int,
              let minor = dict["minor"] as? Int,
              let patch = dict["patch"] as? Int else { return nil }
        return .init(major: major, minor: minor, patch: patch)
    }
    
    static func save(_ config: Config, to url: URL) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let configData = try encoder.encode(config)
            try configData.write(to: url)
        } catch {
            logger.error("Error saving config to: \(url): \(error.localizedDescription)")
        }
    }
    
    static func decodeConfig(fromURL url: URL) throws -> Config {
        let data = try Data(contentsOf: url)
        return try decodeConfig(from: data)
    }
}

enum ConfigManagerError: LocalizedError {
    case cannotDecodeConfig
    case incompatibleVersion
    
    var errorDescription: String? {
        switch self {
        case .cannotDecodeConfig: return "Failed to decode config file."
        case .incompatibleVersion: return "Config file is incompatible with current version."
        }
    }
}

