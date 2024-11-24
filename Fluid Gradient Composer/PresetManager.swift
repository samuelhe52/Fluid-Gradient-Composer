//
//  PresetManager.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/16.
//

import SwiftUI

struct PresetManager: View {
    @Bindable var store: PresetStore
    @State private var editingPreset: Preset?
    @Environment(\.openWindow) private var openWindow
    
    @State private var showCannotDeleteDefaultPresetAlert: Bool = false
    
    var body: some View {
        NavigationSplitView {
            List {
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
            .navigationDestination(for: Preset.ID.self) { id in
                if let index = store.presets.firstIndex(where: { $0.id == id }) {
                    PresetPreview(
                        preset: $store.presets[index],
                        isLocked: store.isLocked(presetId: id),
                        unlock: { store.unlock(withPresetId: id) },
                        lock: { store.lock(withPresetId: id) }
                    )
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
            VStack(spacing: 15) {
                Text("Welcome!")
                    .font(.largeTitle)
                Text("Choose a preset to start")
                    .foregroundStyle(.gray)
            }
        }
    }
    
    // MARK: - Preset List creation
    @ViewBuilder
    private func buildPresetList(_ presets: [Preset]) -> some View {
        ForEach(presets) { preset in
            let locked = store.isLocked(presetId: preset.id)
            let pinned = store.isPinned(presetId: preset.id)
            NavigationLink(value: preset.id) {
                VStack(alignment: .leading) {
                    Text(preset.name)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    if !locked {
                        editButton(preset: preset, locked: locked)
                    } else {
                        lockButton(preset: preset, locked: locked)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if !locked {
                        deleteButton(preset: preset, locked: locked)
                    }
                    pinButton(preset: preset, pinned: pinned)
                    lockButton(preset: preset, locked: locked)
                }
                .contextMenu { contextMenu(forPreset: preset) }
            }
        }
        .onMove { indexSet, newIndex in
            let realIndices = indexSet.compactMap {
                store.presets.firstIndex(of: presets[$0])
            }
            let realNewIndex = store.presets.firstIndex { preset in
                preset.id == store.presets[newIndex].id
            }
            if let realNewIndex {
                store.presets.move(fromOffsets: IndexSet(realIndices), toOffset: realNewIndex)
            }
        }
    }

    // MARK: - Context Menu
    @ViewBuilder
    private func contextMenu(forPreset preset: Preset) -> some View {
        let locked = store.isLocked(presetId: preset.id)
        let pinned = store.isPinned(presetId: preset.id)
        Group {
            editButton(preset: preset, locked: locked)
                .tint(.primary) // Override tint for context menu
            pinButton(preset: preset, pinned: pinned)
                .tint(.primary) // Override tint for context menu
            LazyShareLink { [store.exportPreset(preset)!] }
            lockButton(preset: preset, locked: locked)
            openInNewWindowButton(preset: preset)
            Button(role: .destructive) {
                let indexSet = [store.presets.firstIndex(of: preset)].compactMap(\.self)
                deletePresets(at: IndexSet(indexSet))
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .disabled(locked)
            .alert("Delete Preset", isPresented: $showCannotDeleteDefaultPresetAlert) {
                Button("OK") { }
            } message: {
                Text("Cannot delete the default preset.")
            }
        }
    }
    
    // MARK: - Buttons
    private func editButton(preset: Preset, locked: Bool) -> some View {
        Button {
            editingPreset = preset
            logger.info("Editing preset \(preset.name)")
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .disabled(locked)
        .tint(locked ? .gray : .blue)
    }

    private func deleteButton(preset: Preset, locked: Bool) -> some View {
        Button(role: .destructive) {
            do {
                try store.deletePreset(withId: preset.id)
            } catch {
                logger.error("Failed to delete preset \(preset.name, privacy: .public): \(error)")
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .disabled(locked)
    }

    private func pinButton(preset: Preset, pinned: Bool) -> some View {
        Button {
            if pinned {
                store.unpin(withPresetId: preset.id)
            } else {
                store.pin(withPresetId: preset.id)
            }
        } label: {
            Label(pinned ? "Unpin" : "Pin",
                  systemImage: pinned ? "pin.slash" : "pin")
        }
        .tint(.orange)
    }

    private func lockButton(preset: Preset, locked: Bool) -> some View {
        Button {
            withAnimation {
                if locked {
                    store.unlock(withPresetId: preset.id)
                } else {
                    store.lock(withPresetId: preset.id)
                }
            }
        } label: {
            Label(locked ? "Unlock" : "Lock",
                  systemImage: locked ? "lock.slash" : "lock")
        }
    }
    
    @ViewBuilder
    private func openInNewWindowButton(preset: Preset) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            Button {
                openWindow(value: preset.id)
            } label: {
                Label("Open in New Window", systemImage: "rectangle.inset.filled.on.rectangle")
            }
        }
    }
    
    // MARK: - Toolbar
    @State private var importingPreset: Bool = false
    
    private var importButton: some View {
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
    }
    
    private var newPresetButton: some View {
        Button {
            let presetId = withAnimation { store.createNewPreset(withName: "Untitled") }
            if let index = store.presets.firstIndex(where: { $0.id == presetId }) {
                editingPreset = store.presets[index]
            }
        } label: {
            Label("New", systemImage: "plus")
        }
    }
    
    private var managerToolbar: some View {
        Group {
            importButton
            newPresetButton
        }
    }
    
    // MARK: - Tool functions
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
}
