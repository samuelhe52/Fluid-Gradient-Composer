//
//  PresetManager.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/16.
//

import SwiftUI

struct PresetManager: View {
    @ObservedObject var store: PresetStore
    
    @State private var displayCannotDeleteDefaultPresetAlert: Bool = false
    @State private var editingPreset: FGCPreset?
    @State private var selectedPreset: FGCPreset.ID?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.presets) { preset in
                    NavigationLink(
                        destination: PresetPreview(preset: binding(for: preset)),
                        tag: preset.id,
                        selection: $selectedPreset
                    ) {
                        VStack(alignment: .leading) {
                            Text(preset.name)
                        }
                    }
                    .contextMenu { presetContextMenu(presetID: preset.id) }
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
            .sheet(item: $editingPreset) { preset in
                if let index = store.presets.firstIndex(where: { $0.id == preset.id }) {
                    PresetEditor(preset: $store.presets[index])
                }
            }
            
            // Detail view placeholder
            VStack(spacing: 15) {
                Text("Welcome!")
                    .font(.largeTitle)
                Text("Choose a preset to start")
                    .foregroundColor(.gray)
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .alert("Delete Preset", isPresented: $displayCannotDeleteDefaultPresetAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Cannot delete the default preset.")
        }
    }

    private func binding(for preset: FGCPreset) -> Binding<FGCPreset> {
        guard let index = store.presets.firstIndex(where: { $0.id == preset.id }) else {
            fatalError("Preset not found")
        }
        return $store.presets[index]
    }
    
    private func presetContextMenu(presetID: FGCPreset.ID) -> some View {
        Group {
            Button(role: .destructive) {
                do {
                    try store.deletePreset(withID: presetID)
                } catch FGCStoreError.cannotDeleteDefaultPreset {
                    displayCannotDeleteDefaultPresetAlert = true
                    print("Cannot delete default preset")
                } catch {
                    print("Failed to delete preset: \(error)")
                }
            } label: {
                Text("Delete")
            }
            Button("Edit") {
                if let index = store.presets.firstIndex(where: { $0.id == presetID }) {
                    editingPreset = store.presets[index]
                    print("Editing preset \(presetID)")
                }
            }
        }
    }
    
    private func deletePresets(at indexSet: IndexSet) {
        do {
            try store.deletePreset(at: indexSet)
        } catch FGCStoreError.cannotDeleteDefaultPreset {
            displayCannotDeleteDefaultPresetAlert = true
            print("Cannot delete default preset")
        } catch {
            print("Failed to delete preset: \(error)")
        }
    }
    
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                withAnimation { store.newPreset(withName: "Untitled") }
            } label: {
                Label("New", systemImage: "plus")
            }
        }
    }
}

#Preview {
    PresetManager(store: .init())
}
