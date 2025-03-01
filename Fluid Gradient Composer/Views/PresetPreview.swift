//
//  FGCPresetPreview.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/8/11.
//

import SwiftUI
import FluidGradient

struct PresetPreview: View {
    @Binding var preset: Preset
    @State private var isEditing: Bool = false
    @State private var showFullScreenPreview = false
    @State private var showControl: Bool = false
    private var renderer: GradientRenderer
    @Environment(\.openWindow) private var openWindow
    
    init(preset: Binding<Preset>) {
        self._preset = preset
        self.renderer = .init(preset: preset.wrappedValue)
    }
        
    var body: some View {
        VStack {
            gradientWindow
                .matchedTransitionSource(id: "gradientWindow", in: fullScreenPreview)
            bottomBar
        }
        .sheet(isPresented: $showFullScreenPreview) {
            DedicatedFullScreenPreview(coordinator: .shared)
                .onAppear {
                    FullScreenPreviewCoordinator.shared.presentingPreset = preset
                    showControl = false
                }
                .navigationTransition(.zoom(sourceID: "gradientWindow", in: fullScreenPreview))
        }
        .sheet(isPresented: $isEditing) { PresetEditor(preset: $preset) }
        .navigationTitle(preset.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ColorSchemeSwitcher()
        }
        .padding()
    }
    
    @State var displayDeleteDefaultWarning: Bool = false
    @Namespace var fullScreenPreview
    
    @ViewBuilder
    var gradientWindow: some View {
        GradientWindow(withPreset: preset)
            .clipShape(.rect(cornerRadius: 25))
            .onLongPressGesture { showControl = true }
            .onTapGesture {
                if showControl {
                    showControl.toggle()
                }
            }
            .onTapGesture(count: 2) {
                showFullScreenPreview = true
            }
            .overlay {
                controls
                .opacity(showControl ? 1 : 0)
            }
            .animation(.default, value: showControl)
    }
    
    @Namespace private var lockAnimation
    
    @ViewBuilder
    var bottomBar: some View {
        if !preset.locked {
            Slider(value: $preset.speed, in: 0...5)
            HStack {
                Button("Randomize") {
                    preset.randomizeColors()
                }
                Spacer()
                RenderButton()
                    .environment(renderer)
                Button("Lock", systemImage: "lock") {
                    withAnimation {
                        preset.lock()
                    }
                }
                .padding(.horizontal)
                .matchedGeometryEffect(id: "lockState", in: lockAnimation, properties: .position)
                Button("Edit") {
                    isEditing = true
                    logger.info("Editing preset \(preset.id)")
                }
            }
        } else {
            Button {
                withAnimation {
                    preset.unlock()
                }
            } label: {
                Image(systemName: "lock.slash")
                    .font(.title)
            }
            .matchedGeometryEffect(id: "lockState", in: lockAnimation, properties: .position)
            .padding(.top)
        }
    }
    
    @ViewBuilder
    var controls: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            Button {
                showFullScreenPreview = true
            } label: {
                VStack {
                    Image(systemName: "inset.filled.rectangle.portrait")
                        .font(.largeTitle)
                    Text("Preview in Full Screen")
                }
            }
        } else {
            Button {
                openWindow(value: preset.id)
                showControl = false
            } label: {
                VStack {
                    Image(systemName: "rectangle.inset.filled.on.rectangle")
                        .font(.largeTitle)
                    Text("Preview in New Window")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var preset = Preset.default
    PresetPreview(preset: $preset)
}
