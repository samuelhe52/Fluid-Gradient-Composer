//
//  PresetEditorView.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/16.
//

import SwiftUI
import FluidGradient

struct PresetEditorView: View {
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
                    Button("Save and exit") {
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
                        showDiscardChangesAlert = true
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Discard Changes?", isPresented: $showDiscardChangesAlert) {
                Button("Discard", role: .destructive) {
                    preset = originalPreset
                    dismiss()
                }
                Button("Save") { dismiss() }
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

struct ColorPalette: View {
    @Binding var colors: [Preset.BuiltinColor]
    var randomizeColors: () -> Void
    
    @State private var editingColorIndex: Int?
    
    var body: some View {
        Group {
            LazyHGrid(rows: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(colors.indices, id: \.self) { index in
                    ColorBlob(color: $colors[index])
                }
            }
            Button("Randomize") {
                withAnimation {
                    randomizeColors()
                }
            }
        }
    }
}

struct ColorBlob: View {
    @Binding var color: Preset.BuiltinColor
    @State private var isEditing: Bool = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(color.displayColor)
            .frame(width: 40, height: 40)
            .popover(isPresented: $isEditing) {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Preset.BuiltinColor.allCases, id: \.self) { optionColor in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(optionColor.displayColor)
                                .frame(width: 40, height: 40)
                                .onTapGesture {
                                    color = optionColor
                                }
                                .overlay {
                                    Image(systemName: "checkmark")
                                        .opacity(optionColor == color ? 1 : 0)
                                }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .padding()
                .presentationCompactAdaptation(horizontal: .popover, vertical: .popover)
            }
            .onTapGesture { isEditing = true }
    }
}
