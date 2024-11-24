//
//  FullScreenPreview.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/11/17.
//

import SwiftUI

struct FullScreenPreview: View {
    @Environment(PresetStore.self) var store
    @Binding var presetId: Preset.ID?
    @State private var showControls: Bool = false
    @AppStorage("showTimeInFSPreview") private var showTime: Bool = false
    
    var body: some View {
        if let index = store.presets.firstIndex(where: { presetId == $0.id }) {
            GradientWindow(withPreset: store.presets[index])
                .ignoresSafeArea()
                .navigationTitle(store.presets[index].name)
                .onLongPressGesture { toggleControls() }
                .onTapGesture {
                    if showControls {
                        toggleControls()
                    }
                }
                .overlay {
                    ClockView()
                        .opacity(showTime ? 0.8 : 0)
                        .animation(.default, value: showTime)
                        .offset(y: -250)
                    controls(currentPresetName: store.presets[index].name)
                        .opacity(showControls ? 0.8 : 0)
                }
                .statusBarHidden()
        } else {
            Text("No preset selected. This is a probably a bug.")
        }
    }
    
    func controls(currentPresetName: String) -> some View {
        Color.black.opacity(0.3)
            .overlay {
                VStack {
                    Text(currentPresetName)
                        .font(.title)
                        .lineLimit(20)
                    Toggle("Time", isOn: $showTime)
                        .toggleStyle(.button)
                        .scaleEffect(1.2)
                    Picker("Switch Preset", selection: $presetId) {
                        ForEach(store.presets) { preset in
                            Text(preset.name)
                                .tag(preset.id)
                        }
                    }
                    .pickerStyle(.wheel)
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
