//
//  ConfigManager.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/12/1.
//

import Foundation

class ConfigManager {
    static let currentVersion: Config.Version = .init(major: 0, minor: 1, patch: 0)!
    
    static func decodeConfig(from data: Data) throws -> Config {
        if let config = try? JSONDecoder().decode(Config.self,
                                                  from: data) {
            return config
        } else {
//            if let configDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
//                if configDict["version"] == nil {
//                    configDict["version"] == config
//                }
//            } else {
//                throw ConfigManagerError.configDecodeError
//            }
            throw ConfigManagerError.configDecodeError
        }
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
    case configDecodeError
    
    var errorDescription: String? {
        switch self {
        case .configDecodeError:
            return "Failed to decode config file."
        }
    }
}

