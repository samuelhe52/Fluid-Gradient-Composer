//
//  ContentView.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/8/11.
//

import SwiftUI
import FluidGradient

struct ComposerView: View {
    @ObservedObject var presetStore: FGCPresetStore
    
    var body: some View {
        VStack {
            gradient
                .clipShape(RoundedRectangle(cornerRadius: 25))
            Slider(value: $presetStore.speed, in: 0...5)
            HStack {
                Button { presetStore.randomizeColors() } label: { Text("Randomize") }
                Spacer()
                ColorSchemeSwitcher()
            }
            presetManagement
        }
        .padding()
        .navigationTitle("Fluid Gradient Composer")
    }
    
    private var gotoPreset: some View {
        Menu("Switch to") {
            ForEach(presetStore.presets) { preset in
                Button {
                    presetStore.currentPresetID = preset.id
                } label: {
                    Text(preset.name)
                }
            }
        }
    }
    
    private var presetManagement: some View {
        HStack {
            Spacer()
            Menu(presetStore.currentPreset.name) {
                Button(role: .destructive) {
                    deletePreset(withID: presetStore.currentPresetID)
                } label: { Text("Delete") }
                gotoPreset
            }
            Spacer()
            Button { presetStore.addPreset(withName: "Untitled") } label: { Text("Save") }
            Spacer()
        }
    }
    
    private func deletePreset(withID id: FGCPreset.ID) {
        do {
            try presetStore.deleteCurrentPreset(withID: presetStore.currentPresetID)
        } catch FGCStoreError.cannotDeleteDefaultPreset {
            print("Cannot delete default preset!")
        } catch {
            print("An error occurred: \(error.localizedDescription).")
        }
    }
    
    private var gradient: some View {
        FluidGradient(blobs: presetStore.colors,
                      highlights: presetStore.highlights,
                      speed: presetStore.speed)
    }
}

#Preview {
    ComposerView(presetStore: .init())
}
