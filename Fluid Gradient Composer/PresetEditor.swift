//
//  PresetEditor.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/16.
//

import SwiftUI
import FluidGradient

struct PresetEditor: View {
    @Binding var preset: Preset
    @State private var originalPreset: Preset
    @State private var showDiscardChangesAlert: Bool = false
        
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool
    
    init(preset: Binding<Preset>) {
        self._preset = preset
        self.originalPreset = preset.wrappedValue
    }
        
    var body: some View {
        NavigationView {
            Form {
                Section("name") {
                    TextField("Enter a name", text: $preset.name)
                        .disabled(isDefaultPreset)
                        .foregroundStyle(isDefaultPreset ? Color(uiColor: .systemGray) : .primary)
                        .focused($focused)
                }
                Section("colors") {
                    ColorPalette(colors: $preset.colors) { randomizeColors() }
                }
                Section("highlights") {
                    ColorPalette(colors: $preset.highlights) { randomizeHighlights() }
                }
                Section("speed") {
                    Slider(value: $preset.speed, in: 0...5) {
                        Text("\(preset.speed, specifier: "%.2f")")
                            .font(.caption)
                    }
                }
                Section("Preview") {
                    FluidGradient(blobs: preset.colors.displayColors,
                                  highlights: preset.highlights.displayColors,
                                  speed: preset.speed)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .aspectRatio(2/1, contentMode: .fit)
                }
                Section("Options") {
                    Button("Discard Changes", role: .destructive) {
                        preset = originalPreset
                    }
                    Button("Save and dismiss") {
                        dismiss()
                    }
                }
            }
            .onAppear { focused = true }
            .navigationTitle("Preset Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if !(originalPreset == preset) {
                            showDiscardChangesAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog("Are you sure you want to discard changes?",
                                isPresented: $showDiscardChangesAlert,
                                titleVisibility: .visible) {
                Button("Discard", role: .destructive) {
                    preset = originalPreset
                    dismiss()
                }
                Button("Save and dismiss") { dismiss() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    
    private var isDefaultPreset: Bool { preset.id == Preset.default.id }
    
    private func randomizeColors() {
        preset.colors = Preset.generateRandomColors().colors
    }
    
    private func randomizeHighlights() {
        preset.highlights = Preset.generateRandomColors().highlights
    }
}
