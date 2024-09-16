//
//  PresetManager.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/16.
//

import SwiftUI

struct PresetManager: View {
    @ObservedObject var store: PresetStore
    
    @State var displayCannotDeleteDefaultPresetAlert: Bool = false
    @State var editingPresetID: FGCPreset.ID?
    @State var editingPreset: Bool = false
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(store.presets) { preset in
                    NavigationLink(value: preset.id) {
                        VStack(alignment: .leading) {
                            Text(preset.name)
                        }
                        .contextMenu { presetContextMenu(presetID: preset.id) }
                    }
                }
                .onDelete { indexSet in
                    deletePresets(at: indexSet)
                }
                .onMove { indexSet, destination in
                    withAnimation {
                        store.movePreset(from: indexSet, to: destination)
                    }
                }
            }
            .navigationTitle("Presets")
            .toolbar { toolbar }
            .navigationDestination(for: FGCPreset.ID.self) { presetID in
                if let index = store.presets.firstIndex(where: { $0.id == presetID }) {
                    PresetPreview(preset: $store.presets[index])
                }
            }
            .navigationDestination(isPresented: $editingPreset) {
                if let index = store.presets.firstIndex(where: { $0.id == editingPresetID }) {
                    PresetEditor(preset: $store.presets[index])
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .alert("Delete Preset", isPresented: $displayCannotDeleteDefaultPresetAlert) {
                Button("OK") {}
            } message: {
                Text("Cannot delete the default preset.")
            }
        } detail: {
            VStack(spacing: 15) {
                Text("Welcome!")
                    .font(.largeTitle)
                Text("Choose a preset to start")
                    .foregroundStyle(.gray)
            }
        }
    }
    
    private func presetContextMenu(presetID: FGCPreset.ID) -> some View {
        Group {
            Button(role: .destructive) {
                do {
                    try store.deletePreset(withID: presetID)
                } catch FGCStoreError.cannotDeleteDefaultPreset {
                    displayCannotDeleteDefaultPresetAlert = true
                    logger.error("Cannot delete default preset")
                } catch {
                    logger.error("Failed to delete preset: \(error)")
                }
            } label: {
                Text("Delete")
            }
            Button("Edit") {
                editingPresetID = presetID
                editingPreset = true
                logger.info("Editing preset \(presetID)")
            }
        }
    }
    
    private func deletePresets(at indexSet: IndexSet) {
        do {
            try store.deletePreset(at: indexSet)
        } catch FGCStoreError.cannotDeleteDefaultPreset {
            displayCannotDeleteDefaultPresetAlert = true
            logger.error("Cannot delete default preset")
        } catch {
            logger.error("Failed to delete preset: \(error)")
        }
    }
    
    private var toolbar: some View {
        Button {
            withAnimation { store.newPreset(withName: "Untitled") }
        } label: {
            Label("New", systemImage: "plus")
        }
    }
}

#Preview {
    PresetManager(store: .init())
}
