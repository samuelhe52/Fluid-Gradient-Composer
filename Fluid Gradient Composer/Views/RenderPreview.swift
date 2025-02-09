//
//  RenderPreview.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2025/2/9.
//

import SwiftUI

struct RenderPreview: View {
    @Environment(GradientRenderer.self) var renderer
    @State var showConfiguration: Bool = false
    @State var size: CGSize = .init(width: Constants.defaultWidth,
                                    height: Constants.defaultHeight)
    let blur: CGFloat = Constants.defaultBlur
    
    // MARK: - Body
    var body: some View {
        VStack {
            renderedImage
            HStack(spacing: 15) {
                shareButton
                Button {
                    withAnimation(.easeInOut) {
                        showConfiguration.toggle()
                    }
                } label: {
                    Label("Params...", systemImage: "pencil")
                }
                Button("Try again") {
                    withAnimation {
                        renderer.renderImage(size: size, blur: blur)
                    }
                }
            }
            .buttonStyle(.bordered)
            VStack {
                configuration
                    .padding()
            }
        }
    }
    
    // MARK: - Configuration
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.allowsFloats = false
        return formatter
    }()
    
    @ViewBuilder
    private var configuration: some View {
        if showConfiguration {
            VStack(alignment: .center) {
                Divider()
                HStack {
                    TextField("Width", value: $size.width, formatter: formatter)
                        .keyboardType(.numberPad)
                    Text("x")
                    TextField("Height", value: $size.height, formatter: formatter)
                        .keyboardType(.numberPad)
                }.textFieldStyle(.roundedBorder)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    // MARK: - Share Button
    private var shareButton: some View {
        LazyShareLink {
            var uiImage: UIImage? = nil
            switch renderer.renderState {
            case .rendered(let renderedImage):
                uiImage = renderedImage
            default:
                break
            }
            
            guard let uiImage else { return nil }
            guard let data = uiImage.jpegData(compressionQuality: Constants.jpegQuality) else {
                return nil
            }
            
            do {
                let url = URL
                    .temporaryDirectory
                    .appendingPathComponent(renderer.preset.name,
                                            conformingTo: .jpeg)
                try data.write(to: url)
                return [url]
            } catch {
                logger.error("Error writing image data: \(error)")
                return nil
            }
        } label: {
            Label("Save...", systemImage: "square.and.arrow.down")
        }.disabled(!renderer.renderState.rendered)
    }
    
    // MARK: - Image
    @ViewBuilder
    private var renderedImage: some View {
        switch renderer.renderState {
        case .rendered(let uiImage):
            Image(uiImage: uiImage)
                .resizable()
                .clipShape(ProportionalRoundedRectangle(cornerFraction: 0.03))
                .scaledToFit()
                .padding()
        case .rendering:
            ProgressView()
        case .failed:
            Text("Rendering failed. Try again later.")
        default:
            Text("Image missing. This should never happen.")
        }
    }
    
    // MARK: - Constants
    struct Constants {
        static let defaultWidth: CGFloat = 1200
        static let defaultHeight: CGFloat = 2000
        static let defaultBlur: CGFloat = 0.75
        static let jpegQuality: CGFloat = 0.8
    }
}

#Preview {
    RenderPreview()
        .environment(GradientRenderer(preset: .default))
}
