//
//  GradientWindow.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/11/17.
//

import SwiftUI
import FluidGradient

struct GradientWindow: View {
    var preset: Preset
    
    init(withPreset preset: Preset) {
        self.preset = preset
    }
    
    var body: some View {
        FluidGradient(blobs: preset.colors.displayColors,
                      highlights: preset.highlights.displayColors,
                      speed: preset.speed)
    }
}
