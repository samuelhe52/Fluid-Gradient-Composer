//
//  GradientRenderer.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/11/23.
//

import SwiftUI
import UIKit
import FluidGradient

@Observable
class GradientRenderer {
    let preset: Preset
    var renderState: RenderState
    
    init(preset: Preset) {
        self.preset = preset
        self.renderState = .blank
    }
    
    enum RenderState: Equatable {
        case blank
        case rendering
        case rendered(UIImage)
        case failed
        
        var rendered: Bool {
            if case .rendered(_) = self {
                return true
            } else { return false }
        }
    }
    
    @MainActor
    func renderGradient(size: CGSize) -> UIImage? {
        let gradientView = FluidGradientView(
            blobs: preset.colors.displayColors,
            highlights: preset.highlights.displayColors,
            speed: preset.speed)
        return gradientView.renderToImage(size: size)
    }
    
    @MainActor
    func renderImage(size: CGSize = .init(width: 1200, height: 2000),
                     blur: CGFloat = 0.75) {
        let blurValue = min(size.width, size.height)
        renderState = .rendering
        if let uiImage = renderGradient(size: size) {
            let image = Image(uiImage: uiImage)
                .blur(radius: pow(blurValue, blur))
            let imageRenderer = ImageRenderer(content: image)
            let renderedImage = imageRenderer.uiImage!
            renderState = .rendered(renderedImage)
        } else {
            renderState = .failed
            DispatchQueue.main
                .asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.renderState = .blank
            }
        }
    }
}
