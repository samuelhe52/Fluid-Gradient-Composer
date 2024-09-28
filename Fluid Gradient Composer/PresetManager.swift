//
//  PresetManager.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/16.
//

import SwiftUI

struct PresetManager: View {
    @Bindable var store: PresetStore
    @State private var selectedPreset: Preset?
    
    @State private var showCannotDeleteDefaultPresetAlert: Bool = false
    @State private var editingPreset: Preset?
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedPreset) {
                ForEach(store.presets) { preset in
                    NavigationLink(value: preset) {
                        VStack(alignment: .leading) {
                            Text(preset.name)
                        }
                        .contextMenu { contextMenu(forPreset: preset) }
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
            .toolbar { managerToolbar }
            .sheet(item: $editingPreset) { preset in
                if let index = store.presets.firstIndex(where: { $0.id == preset.id }) {
                    PresetEditor(preset: $store.presets[index])
                }
            }
        } detail: {
            PresetDetail(store: store, selectedPreset: selectedPreset)
        }
    }
    
    private func contextMenu(forPreset preset: Preset) -> some View {
        Group {
            Button(role: .destructive) {
                do {
                    try store.deletePreset(withId: preset.id)
                } catch FGCStoreError.cannotDeleteDefaultPreset {
                    showCannotDeleteDefaultPresetAlert = true
                    logger.warning("Cannot delete default preset")
                } catch {
                    logger.error("Failed to delete preset: \(error)")
                }
            } label: {
                Text("Delete")
            }
            .alert("Delete Preset", isPresented: $showCannotDeleteDefaultPresetAlert) {
                Button("OK") { }
            } message: {
                Text("Cannot delete the default preset.")
            }
            Button("Edit") {
                editingPreset = preset
                logger.info("Editing preset \(preset.name)")
            }
        }
    }
    
    private func deletePresets(at indexSet: IndexSet) {
        do {
            try store.deletePreset(at: indexSet)
        } catch FGCStoreError.cannotDeleteDefaultPreset {
            showCannotDeleteDefaultPresetAlert = true
            logger.warning("Cannot delete default preset")
        } catch {
            logger.error("Failed to delete preset: \(error)")
        }
    }
    
    private var managerToolbar: some ToolbarContent {
        ToolbarItemGroup {
            Button {
                let presetId = withAnimation { store.addNewPreset(withName: "Untitled") }
                if let index = store.presets.firstIndex(where: { $0.id == presetId }) {
                    editingPreset = store.presets[index]
                }
            } label: {
                Label("New", systemImage: "plus")
            }
            EditButton()
        }
    }
}

struct PresetDetail: View {
    @Bindable var store: PresetStore
    var selectedPreset: Preset?
    
    var body: some View {
        if let selectedPresetId = selectedPreset?.id,
           let index = store.presets.firstIndex(where: { $0.id == selectedPresetId }) {
            PresetPreview(preset: $store.presets[index])
        } else {
            VStack(spacing: 15) {
                Text("Welcome!")
                    .font(.largeTitle)
                Text("Choose a preset to start")
                    .foregroundStyle(.gray)
            }
        }
    }
}
