//
//  ImageRenderer.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/11/23.
//

import SwiftUI
import UIKit
import FluidGradient

struct RenderButton: View {
    var preset: Preset
    @State var renderState: RenderState = .blank
    @State var showingImage: Bool = false
    
    var body: some View {
        Button {
            Task { await renderImage(preset: preset) }
        } label: {
            switch renderState {
            case .blank:
                Label("Render", systemImage: "photo")
                    .labelStyle(.iconOnly)
            case .rendering:
                ProgressView()
            case .rendered:
                Label("Success", systemImage: "checkmark.circle")
            }
        }
        .disabled(renderState == .rendering)
        .animation(.easeInOut, value: renderState)
        .popover(isPresented: $showingImage) {
            switch renderState {
            case .rendered(let uiImage):
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            default:
                Text("Image missing. This should never happen.")
            }
        }.onChange(of: showingImage) { oldValue, newValue in
            if oldValue && !newValue {
                renderState = .blank
            }
        }
    }
    
    nonisolated
    private func renderImage(preset: Preset) async {
        await MainActor.run { renderState = .rendering }
        let filter: BlurFilter = .gaussianBlur
        let blurRadius: CGFloat = 150
        
        if let image = await renderGradient(preset: preset,
                                            size: .init(width: 1200, height: 2000),
                                            blurFilter: filter,
                                            blurRadius: blurRadius) {
            await MainActor.run {
                let uiImage = UIImage(cgImage: image)
                renderState = .rendered(uiImage)
                showingImage = true
            }
        }
    }
    
    enum RenderState: Equatable {
        case blank
        case rendering
        case rendered(UIImage)
        
        var rendering: Bool {
            switch self {
            case .rendering: return true
            default: return false
            }
        }
    }
}

func renderGradient(preset: Preset, size: CGSize, blurFilter: BlurFilter, blurRadius: CGFloat) async -> CGImage? {
    let gradientView = await FluidGradientView(
        blobs: preset.colors.displayColors,
        highlights: preset.highlights.displayColors,
        speed: preset.speed)
    return await gradientView.renderToImage(size: size, blurFilter: blurFilter, blurRadius: blurRadius)
}
