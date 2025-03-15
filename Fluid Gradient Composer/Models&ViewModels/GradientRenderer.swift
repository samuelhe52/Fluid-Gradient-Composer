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
    func renderImage(size: RenderSize, blur: CGFloat = 0.75) {
        let blurValue = min(size.width, size.height)
        renderState = .rendering
        if let uiImage = renderGradient(size: size.cgSize) {
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

struct RenderSize: Codable, RawRepresentable, Equatable {
    var width: Double
    var height: Double
    
    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    init(_ cgSize: CGSize) throws {
        self.width = cgSize.width
        self.height = cgSize.height
    }
    
    var cgSize: CGSize {
        .init(width: width, height: height)
    }
    
    // RawRepresentable implementation
    typealias RawValue = String
    
    init?(rawValue: String) {
        let components = rawValue.split(separator: ",").compactMap { Double($0) }
        guard components.count == 2 else { return nil }
        self.width = components[0]
        self.height = components[1]
    }
    
    var rawValue: String {
        "\(width),\(height)"
    }
}
