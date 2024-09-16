//
//  ContentView.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/8/11.
//

import SwiftUI
import FluidGradient

struct ComposerView: View {
    @Binding var preset: FGCPreset
    
    var body: some View {
        VStack {
            gradient
                .clipShape(RoundedRectangle(cornerRadius: 25))
            Slider(value: $preset.speed, in: 0...5)
            Button { preset.randomizeColors() } label: { Text("Randomize") }
        }
        .padding()
        .navigationTitle(preset.name)
        .toolbar {
            ColorSchemeSwitcher()
        }
    }
    
    @State var displayDeleteDefaultWarning: Bool = false
    
    private var gradient: some View {
        FluidGradient(blobs: preset.colors.displayColors,
                      highlights: preset.highlights.displayColors,
                      speed: preset.speed)
    }
}
