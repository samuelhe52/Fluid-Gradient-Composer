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
                if !store.pinnedPresets.isEmpty {
                    Section("Pinned") {
                        buildPresetList(store.pinnedPresets)
                    }
                }
                if !store.unpinnedPresets.isEmpty {
                    Section {
                        buildPresetList(store.unpinnedPresets)
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
    
    private func buildPresetList(_ presets: [Preset]) -> some View {
        ForEach(presets) { preset in
            NavigationLink(value: preset) {
                VStack(alignment: .leading) {
                    Text(preset.name)
                }
                .contextMenu { contextMenu(forPreset: preset) }
            }
        }
        .onDelete { indexSet in
            let realIndices = indexSet.compactMap {
                store.presets.firstIndex(of: presets[$0])
            }
            deletePresets(at: IndexSet(realIndices))
        }
        .onMove { indexSet, newIndex in
            let realIndices = indexSet.compactMap {
                store.presets.firstIndex(of: presets[$0])
            }
            let realNewIndex = store.presets.firstIndex { preset in
                preset.id == presets[newIndex].id
            }
            if let realNewIndex {
                store.presets.move(fromOffsets: IndexSet(realIndices), toOffset: realNewIndex)
            }
        }
    }
    
    private func contextMenu(forPreset preset: Preset) -> some View {
        Group {
            Button {
                editingPreset = preset
                logger.info("Editing preset \(preset.name)")
            } label: { Label("Edit", systemImage: "pencil") }
            Button {
                if store.isPresetPinned(preset.id) {
                    store.unpin(withPresetId: preset.id)
                } else {
                    store.pin(withPresetId: preset.id)
                }
            } label: {
                Label(store.isPresetPinned(preset.id) ? "Unpin" : "Pin",
                      systemImage: store.isPresetPinned(preset.id) ? "pin.slash" : "pin")
            }
            LazyShareLink { [store.exportPreset(preset)!] }
            Button(role: .destructive) {
                let indexSet = [store.presets.firstIndex(of: preset)].compactMap(\.self)
                deletePresets(at: IndexSet(indexSet))
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .alert("Delete Preset", isPresented: $showCannotDeleteDefaultPresetAlert) {
                Button("OK") { }
            } message: {
                Text("Cannot delete the default preset.")
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
    
    @State private var importingPreset: Bool = false
    
    private var managerToolbar: some View {
        Group {
            Button {
                importingPreset = true
            } label: {
                Label("Import", systemImage: "square.and.arrow.down")
            }
            .fileImporter(isPresented: $importingPreset,
                          allowedContentTypes: [.fgcpreset],
                          allowsMultipleSelection: true) { results in
                switch results {
                case .success(let urls):
                    logger.debug("Importing presets: \(urls)")
                    for url in urls {
                        do {
                            if url.startAccessingSecurityScopedResource() {
                                defer { url.stopAccessingSecurityScopedResource() }
                                try store.addNewPreset(fromURL: url)
                            } else {
                                logger.error("Failed to access security-scoped resource: \(url)")
                            }
                        } catch {
                            logger.error("Failed to import preset: \(error)")
                        }
                    }
                case .failure(let error):
                    logger.error("Error importing presets: \(error)")
                }
            }
            Button {
                let presetId = withAnimation { store.createNewPreset(withName: "Untitled") }
                if let index = store.presets.firstIndex(where: { $0.id == presetId }) {
                    editingPreset = store.presets[index]
                }
            } label: {
                Label("New", systemImage: "plus")
            }
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
