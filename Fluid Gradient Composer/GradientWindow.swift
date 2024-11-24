//
//  GradientWindow.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/11/17.
//

import SwiftUI
import FluidGradient

/// The universal component used to display a `FluidGradient` with a given `Preset`.
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
