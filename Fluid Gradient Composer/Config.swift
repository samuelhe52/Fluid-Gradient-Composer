//
//  Config.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/10/13.
//

import Foundation

struct Config: Codable {
    var presets: [Preset]
    var pinnedPresetIds: Set<Preset.ID>
}
