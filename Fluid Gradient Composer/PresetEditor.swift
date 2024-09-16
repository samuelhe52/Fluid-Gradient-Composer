//
//  PresetEditor.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/16.
//

import SwiftUI
import FluidGradient

struct PresetEditor: View {
    @Binding var preset: FGCPreset
        
    var body: some View {
        Form {
            Section("name") {
                TextField("Enter a name", text: $preset.name)
                    .disabled(isDefaultPreset)
                    .foregroundStyle(isDefaultPreset ? Color(uiColor: .systemGray) : .primary)
            }
            Section("colors") {
                ColorPalette(colors: $preset.colors) { randomizeColors() }
            }
            Section("highlights") {
                ColorPalette(colors: $preset.highlights) { randomizeHighlights() }
            }
            Section("speed") {
                Slider(value: $preset.speed, in: 0...5) {
                    Text("\(preset.speed, specifier: "%.2f")")
                        .font(.caption)
                }
            }
            Section("Preview") {
                FluidGradient(blobs: preset.colors.displayColors,
                              highlights: preset.highlights.displayColors,
                              speed: preset.speed)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .aspectRatio(2/1, contentMode: .fit)
            }
        }
    }
    
    var isDefaultPreset: Bool { preset.id == FGCPreset.default.id }
    
    private func randomizeColors() {
        preset.colors = FGCPreset.generateRandomColors().colors
    }
    
    private func randomizeHighlights() {
        preset.highlights = FGCPreset.generateRandomColors().highlights
    }
}

struct ColorPalette: View {
    @Binding var colors: [FGCPreset.BuiltinColor]
    var randomizeColors: () -> Void
    
    var body: some View {
        Group {
            LazyHGrid(rows: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(colors.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colors[index].displayColor)
                        .frame(width: 40, height: 40)
                }
            }
            Button("Randomize") {
                withAnimation {
                    randomizeColors()
                }
            }
        }
    }
}
