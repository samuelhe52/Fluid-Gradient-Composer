//
//  FullScreenPreview.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/11/17.
//

import SwiftUI

@Observable @MainActor
class FullScreenPreviewCoordinator {
    var presentingPresetId: Preset.ID?
    var presentingPreset: Preset?
    
    static var shared = FullScreenPreviewCoordinator()
}

// MARK: - Allow switching
struct FullScreenPreview: View {
    @Environment(PresetStore.self) var store
    @Bindable var coordinator: FullScreenPreviewCoordinator
    @State private var showControls: Bool = true
    @AppStorage("showTimeInFSPreview") private var showTime: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        if let index = store.presets.firstIndex(where: { coordinator.presentingPresetId == $0.id }) {
            GradientWindow(withPreset: store.presets[index])
                .ignoresSafeArea()
                .navigationTitle(store.presets[index].name)
                .onLongPressGesture { toggleControls() }
                .overlay {
                    Color.black
                        .opacity(showControls ? 0.5 : 0)
                        .ignoresSafeArea()
                }
            // MARK: - Controls
                .overlay(alignment: .bottom) {
                    let isDeviceIPhone = UIDevice.current.userInterfaceIdiom == .phone
                    Button { dismiss() } label: {
                        VStack {
                            Image(systemName: "xmark.circle")
                                .font(.largeTitle)
                            Text("Back")
                        }
                    }
                    .offset(y: -30)
                    .opacity(isDeviceIPhone && showControls ? 0.8 : 0)
                }
                .onTapGesture {
                    if showControls {
                        toggleControls()
                    }
                }
            // MARK: Clock
                .overlay {
                    ClockView()
                        .opacity(showTime ? 0.8 : 0)
                        .animation(.default, value: showTime)
                        .offset(y: -250)
                    controls(currentPresetName: store.presets[index].name)
                        .opacity(showControls ? 0.8 : 0)
                }
                .toolbar(.hidden)
                .statusBarHidden()
        } else {
            Text("No preset selected. This is a probably a bug.")
        }
    }
    
    // MARK: - Controls
    func controls(currentPresetName: String) -> some View {
        Color.clear.opacity(0.3)
            .overlay {
                VStack {
                    Text(currentPresetName)
                        .font(.title)
                        .lineLimit(20)
                    Picker("Switch Preset", selection: $coordinator.presentingPresetId) {
                        ForEach(store.presets) { preset in
                            Text(preset.name)
                                .tag(preset.id)
                        }
                    }
                    .pickerStyle(.wheel)
                    Toggle("Time", isOn: $showTime)
                        .toggleStyle(.button)
                        .background(Color.clear)
                        .scaleEffect(1.2)
                }
                .padding()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(width: 250, height: 250)
    }
    
    func toggleControls() {
        withAnimation {
            showControls.toggle()
        }
    }
}

// MARK: - Dedicated
struct DedicatedFullScreenPreview: View {
    @Bindable var coordinator: FullScreenPreviewCoordinator
    @State private var showControls: Bool = false
    @AppStorage("showTimeInFSPreview") private var showTime: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        if let preset = coordinator.presentingPreset {
            GradientWindow(withPreset: preset)
                .ignoresSafeArea()
                .onLongPressGesture { toggleControls() }
                .navigationTitle(preset.name)
                .overlay {
                    Color.black
                        .opacity(showControls ? 0.5 : 0)
                        .ignoresSafeArea()
                }
            // MARK: - Controls
                .overlay(alignment: .bottom) {
                    Button { dismiss() } label: {
                        VStack {
                            Image(systemName: "xmark.circle")
                                .font(.largeTitle)
                            Text("Back")
                        }
                    }
                    .offset(y: -30)
                    .opacity(showControls ? 0.8 : 0)
                }
                .onTapGesture {
                    if showControls {
                        toggleControls()
                    }
                }
            // MARK: Clock
                .overlay {
                    ClockView()
                        .opacity(showTime ? 0.8 : 0)
                        .animation(.default, value: showTime)
                        .offset(y: -250)
                    controls(currentPresetName: preset.name)
                        .opacity(showControls ? 0.8 : 0)
                }
                .toolbar(.hidden)
                .statusBarHidden()
        } else {
            Text("Missing preset. This is a probably a bug.")
        }
    }
    
    // MARK: - Controls
    func controls(currentPresetName: String) -> some View {
        Color.clear.opacity(0.3)
            .overlay {
                VStack {
                    Text(currentPresetName)
                        .font(.title)
                        .lineLimit(20)
                    Toggle("Time", isOn: $showTime)
                        .toggleStyle(.button)
                        .scaleEffect(1.2)
                }
                .padding()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(width: 250, height: 150)
    }
    
    func toggleControls() {
        withAnimation {
            showControls.toggle()
        }
    }
}

// MARK: - Previews
#Preview {
    @Previewable @State var store = PresetStore()
    @Previewable @State var coordinator = FullScreenPreviewCoordinator()
    @Previewable @State var presetId: Preset.ID?
    
    
    FullScreenPreview(coordinator: coordinator)
        .onAppear { coordinator.presentingPresetId = store.presets.first?.id }
        .environment(store)
}