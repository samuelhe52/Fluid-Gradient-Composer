//
//  PresetManager.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/16.
//

import SwiftUI

struct PresetManager: View {
    @ObservedObject var store: PresetStore
    @State private var selectedPresetID: Preset.ID?
    
    @State private var displayCannotDeleteDefaultPresetAlert: Bool = false
    @State private var editingPreset: Preset?

    var body: some View {
        NavigationView {
            List(selection: $selectedPresetID) {
                ForEach(store.presets) { preset in
                    NavigationLink(
                        destination: PresetPreview(preset: binding(for: preset)),
                        tag: preset.id,
                        selection: $selectedPresetID
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
            .alert(isPresented: $displayCannotDeleteDefaultPresetAlert) {
                Alert(
                    title: Text("Delete Preset"),
                    message: Text("Cannot delete the default preset."),
                    dismissButton: .default(Text("OK"))
                )
            }
            
            detailView
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
    
    @ViewBuilder
    private var detailView: some View {
        Group {
            if let selectedID = selectedPresetID,
               let index = store.presets.firstIndex(where: { $0.id == selectedID }) {
                PresetPreview(preset: $store.presets[index])
            } else {
                VStack(spacing: 15) {
                    Text("Welcome!")
                        .font(.largeTitle)
                    Text("Choose a preset to start")
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private func binding(for preset: Preset) -> Binding<Preset> {
        guard let index = store.presets.firstIndex(where: { $0.id == preset.id }) else {
            fatalError("Preset not found")
        }
        return $store.presets[index]
    }
        
    private func presetContextMenu(presetID: Preset.ID) -> some View {
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
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                let presetID = withAnimation { store.newPreset(withName: "Untitled") }
                if let index = store.presets.firstIndex(where: { $0.id == presetID }) {
                    editingPreset = store.presets[index]
                }
            } label: {
                Label("New", systemImage: "plus")
            }
            EditButton()
        }
    }
}

struct PresetManager_Previews: PreviewProvider {
    static var previews: some View {
        PresetManager(store: PresetStore())
    }
}
