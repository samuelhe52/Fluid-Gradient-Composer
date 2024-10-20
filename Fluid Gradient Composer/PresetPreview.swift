//
//  FGCPresetPreview.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/8/11.
//

import SwiftUI
import FluidGradient

struct PresetPreview: View {
    @Binding var preset: Preset
    @State private var isEditing: Bool = false
    
    var isLocked: Bool = false
    var unlock: () -> Void
    var lock: () -> Void
    @State var showLockedHint: Bool = false
    
    var body: some View {
        VStack {
            gradient
                .clipShape(RoundedRectangle(cornerRadius: 25))
            if !isLocked {
                Slider(value: $preset.speed, in: 0...5)
                HStack {
                    Button("Randomize") { preset.randomizeColors() }
                    Spacer()
                    Button("Lock", systemImage: "lock") {
                        withAnimation {
                            lock()
                        }
                    }.padding(.horizontal)
                    Button("Edit") {
                        isEditing = true
                        logger.info("Editing preset \(preset.id)")
                    }
                }
            } else {
                Button {
                    withAnimation {
                        unlock()
                    }
                } label: {
                    Image(systemName: "lock.slash")
                        .font(.title)
                }
                .padding(.top)
            }
        }
        .sheet(isPresented: $isEditing) { PresetEditor(preset: $preset) }
        .navigationTitle(preset.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ColorSchemeSwitcher()
        }
        .padding()
    }
    
    @State var displayDeleteDefaultWarning: Bool = false
    
    private var gradient: some View {
        FluidGradient(blobs: preset.colors.displayColors,
                      highlights: preset.highlights.displayColors,
                      speed: preset.speed)
    }
}
