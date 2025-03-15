//
//  RenderButton.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2025/1/12.
//

import SwiftUI

struct RenderButton: View {
    @Environment(GradientRenderer.self) var renderer
    @AppStorage("RenderSize") var renderSize: RenderSize = .init(width: 1200, height: 2000)
    @State var showRenderPreview: Bool = false
    
    var body: some View {
        Button {
            renderer.renderImage(size: renderSize)
            showRenderPreview = true
        } label: {
            switch renderer.renderState {
            case .blank:
                Label("Render", systemImage: "photo")
                    .labelStyle(.iconOnly)
            case .rendering:
                ProgressView()
            case .rendered:
                Label("Success", systemImage: "checkmark.circle")
            case .failed:
                Label("Failed", systemImage: "xmark.circle")
            }
        }
        .disabled(renderer.renderState == .rendering)
        .animation(.easeInOut, value: renderer.renderState)
        .popover(isPresented: $showRenderPreview) {
            RenderPreview()
                .environment(renderer)
                .presentationBackground(.thickMaterial)
        }
        .onChange(of: showRenderPreview) { oldValue, newValue in
            if oldValue && !newValue {
                renderer.renderState = .blank
            }
        }
    }
}
