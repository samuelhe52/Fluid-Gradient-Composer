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
                    PresetPreview(preset: $store.presets[index])
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
            let locked = preset.locked
            let pinned = store.isPinned(presetId: preset.id)
            NavigationLink(value: preset.id) {
                VStack(alignment: .leading) {
                    Text(preset.name)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    if !locked {
                        editButton(preset: preset)
                    } else {
                        lockButton(presetId: preset.id)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if !locked {
                        deleteButton(preset: preset)
                    }
                    pinButton(preset: preset, pinned: pinned)
                    lockButton(presetId: preset.id)
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
        let locked = preset.locked
        let pinned = store.isPinned(presetId: preset.id)
        Group {
            editButton(preset: preset)
                .tint(.primary) // Override tint for context menu
            pinButton(preset: preset, pinned: pinned)
                .tint(.primary) // Override tint for context menu
            LazyShareLink { [store.exportPreset(preset)!] }
            lockButton(presetId: preset.id)
            fullScreenPreviewButton(preset: preset)
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
    private func editButton(preset: Preset) -> some View {
        Button {
            editingPreset = preset
            logger.info("Editing preset \(preset.name)")
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .disabled(preset.locked)
        .tint(preset.locked ? .gray : .blue)
    }

    private func deleteButton(preset: Preset) -> some View {
        Button(role: .destructive) {
            do {
                try store.deletePreset(withId: preset.id)
            } catch {
                logger.error("Failed to delete preset \(preset.name, privacy: .public): \(error)")
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .disabled(preset.locked)
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

    @ViewBuilder
    private func lockButton(presetId: Preset.ID) -> some View {
        if let index = store.presets.firstIndex(where: { $0.id == presetId }) {
            let locked = store.presets[index].locked
            Button {
                withAnimation {
                    if locked {
                        store.presets[index].unlock()
                    } else {
                        store.presets[index].lock()
                    }
                }
            } label: {
                Label(locked ? "Unlock" : "Lock",
                      systemImage: locked ? "lock.slash" : "lock")
            }
        }
    }
    
    @ViewBuilder
    private func fullScreenPreviewButton(preset: Preset) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            Button {
                openWindow(value: preset.id)
            } label: {
                Label("Open in New Window",
                      systemImage: "rectangle.inset.filled.on.rectangle")
            }
        } else {
            NavigationLink {
                FullScreenPreview(coordinator: .shared)
                    .environment(store)
            } label: {
                Label("Full Screen Preview",
                      systemImage: "inset.filled.rectangle.portrait")
            }
            .onAppear { FullScreenPreviewCoordinator.shared.presentingPresetId = preset.id }
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
                    withAnimation {
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
    
    @State var showConfigManagementMenu: Bool = false
    @State var applyingCustomConfig: Bool = false
    @State var showFileImporter: Bool = false
    @State var applyFailed: Bool = false
    @State var applyError: FGCStoreError?
    private var configManagement: some View {
        Menu {
            LazyShareLink("Export Config") { [PresetStore.configURL] }
            Button { applyingCustomConfig = true } label: {
                Label("Apply Custom Config", systemImage: "clock.arrow.2.circlepath")
            }
        } label: {
            Label("Manage Config", systemImage: "arrow.2.circlepath.circle")
        }
        .confirmationDialog("Apply Custom Config",
                            isPresented: $applyingCustomConfig) {
            Button("Choose Custom Config") {
                logger.info("Applying custom config...")
                showFileImporter = true
            }
        } message: {
            Text("Apply custom config? This will overwrite all existing presets.")
        }
        .alert(isPresented: $applyFailed,
               error: applyError) { _ in
            Button("OK", role: .cancel) { applyError = nil }
        } message: { error in
            Text("An error occurred while applying the custom config: \(error.localizedDescription).")
        }
        .fileImporter(isPresented: $showFileImporter,
                      allowedContentTypes: [.fgcconfig]) { result in
            switch result {
            case .success(let configURL):
                withAnimation {
                    do {
                        if configURL.startAccessingSecurityScopedResource() {
                            defer { configURL.stopAccessingSecurityScopedResource() }
                            try store.applyNewConfig(fromURL: configURL)
                            logger.info("Applied custom config.")
                        } else {
                            logger.error("Failed to access config file.")
                        }
                    } catch let error as FGCStoreError {
                        applyFailed = true
                        applyError = error
                    } catch {
                        applyFailed = true
                        applyError = .other(error)
                        logger.error("Failed to apply config: \(error.localizedDescription).")
                    }
                }
            case .failure(let error):
                logger.error("Failed to apply config: \(error.localizedDescription)")
                applyFailed = true
                applyError = .fileImportError(error)
            }
        }
    }
    
    private var managerToolbar: some View {
        Group {
            configManagement
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
