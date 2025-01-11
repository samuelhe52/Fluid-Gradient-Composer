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
            Task { renderImage(preset: preset) }
        } label: {
            switch renderState {
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
    
    private func renderImage(preset: Preset,
                             size: CGSize = .init(width: 1200, height: 2000),
                             blur: CGFloat = 0.75) {
        let blurValue = min(size.width, size.height)
        renderState = .rendering
        if let cgImage = renderGradient(preset: preset,
                                      size: .init(width: 1200, height: 2000)) {
            let image = Image(uiImage: UIImage(cgImage: cgImage))
                .blur(radius: pow(blurValue, blur))
            let renderer = ImageRenderer(content: image)
            let uiImage = renderer.uiImage!
            renderState = .rendered(uiImage)
            showingImage = true
        } else {
            renderState = .failed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                renderState = .blank
            }
        }
    }
    
    enum RenderState: Equatable {
        case blank
        case rendering
        case rendered(UIImage)
        case failed
        
        var rendering: Bool {
            switch self {
            case .rendering: return true
            default: return false
            }
        }
    }
}

@MainActor
func renderGradient(preset: Preset, size: CGSize) -> CGImage? {
    let gradientView = FluidGradientView(
        blobs: preset.colors.displayColors,
        highlights: preset.highlights.displayColors,
        speed: preset.speed)
    return gradientView.renderToImage(size: size)
}
