//
//  RenderButton.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2025/1/12.
//

import SwiftUI

struct RenderButton: View {
    @Environment(GradientRenderer.self) var renderer
    @State var showingImage: Bool = false
    
    var body: some View {
        Button {
            renderer.renderImage()
            showingImage = true
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
        .popover(isPresented: $showingImage) {
            popoverContent
                .presentationBackground(.thinMaterial)
        }
        .onChange(of: showingImage) { oldValue, newValue in
            if oldValue && !newValue {
                renderer.renderState = .blank
            }
        }
    }
    
    @ViewBuilder
    private var popoverContent: some View {
        switch renderer.renderState {
        case .rendered(let uiImage):
            Image(uiImage: uiImage)
                .resizable()
                .clipShape(ProportionalRoundedRectangle(cornerFraction: 0.03))
                .scaledToFit()
                .padding()
        default:
            Text("Image missing. This should never happen.")
        }
    }
}
