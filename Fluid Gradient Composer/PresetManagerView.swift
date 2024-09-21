//
//  PresetManagerView.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/16.
//

import SwiftUI

struct PresetManagerView: View {
    @ObservedObject var store: PresetStore
    @State private var selectedPresetID: FGCPreset.ID?
    
    @State private var showCannotDeleteDefaultPresetAlert: Bool = false
    @State private var editingPreset: FGCPreset?
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedPresetID) {
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
            .toolbar { managerToolbar }
            .navigationDestination(for: FGCPreset.ID.self) { presetID in
                if let index = store.presets.firstIndex(where: { $0.id == presetID }) {
                    PresetPreview(preset: $store.presets[index])
                }
            }
            .sheet(item: $editingPreset) { preset in
                if let index = store.presets.firstIndex(where: { $0.id == preset.id }) {
                    PresetEditorView(preset: $store.presets[index])
                }
            }
            .alert("Delete Preset", isPresented: $showCannotDeleteDefaultPresetAlert) {
                Button("OK") {}
            } message: {
                Text("Cannot delete the default preset.")
            }
        } detail: {
            detailView
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        if let selectedID = selectedPresetID,
           let index = store.presets.firstIndex(where: { $0.id == selectedID }) {
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
        
    private func presetContextMenu(presetID: FGCPreset.ID) -> some View {
        Group {
            Button(role: .destructive) {
                do {
                    try store.deletePreset(withID: presetID)
                } catch FGCStoreError.cannotDeleteDefaultPreset {
                    showCannotDeleteDefaultPresetAlert = true
                    logger.warning("Cannot delete default preset")
                } catch {
                    logger.error("Failed to delete preset: \(error)")
                }
            } label: {
                Text("Delete")
            }
            Button("Edit") {
                if let index = store.presets.firstIndex(where: { $0.id == presetID }) {
                    editingPreset = store.presets[index]
                    logger.info("Editing preset \(presetID)")
                }
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
                withAnimation { store.newPreset(withName: "Untitled") }
            } label: {
                Label("New", systemImage: "plus")
            }
            EditButton()
        }
    }
}

#Preview {
    PresetManagerView(store: .init())
}
