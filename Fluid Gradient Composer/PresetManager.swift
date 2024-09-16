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
    @State private var editingPresetID: FGCPreset.ID?
    @State private var editingPreset: Bool = false
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
            .background(
                NavigationLink(
                    destination: editingPresetDestination,
                    isActive: $editingPreset,
                    label: { EmptyView() }
                )
            )
            
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
    
    @ViewBuilder
    private var editingPresetDestination: some View {
        if let index = store.presets.firstIndex(where: { $0.id == editingPresetID }) {
            PresetEditor(preset: $store.presets[index])
        } else {
            EmptyView()
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
                editingPresetID = presetID
                editingPreset = true
                print("Editing preset \(presetID)")
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
