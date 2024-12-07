//
//  ConfigMigration.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/12/7.
//

import Foundation

struct ConfigMigration {
    static let compatibleVersions: Set<Config.Version> = []

    static func migrate(configDict dict: [String: Any], version: Config.Version) throws -> Config {
        // Switch version to determine which migration function to use...
        switch version {
        default: throw ConfigManagerError.incompatibleVersion
        }
    }
    
    // MARK: Waiting for version changes...
    
}
