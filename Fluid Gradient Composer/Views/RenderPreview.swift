//
//  RenderPreview.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2025/2/9.
//

import SwiftUI

struct RenderPreview: View {
    @Environment(GradientRenderer.self) var renderer
    @Environment(\.colorScheme) var colorScheme
    @State var showConfiguration: Bool = true
    @State var showImage: Bool = true
    @State var lockedAspectRatio: CGFloat?
    @FocusState private var focusedField: InputField?
    @AppStorage("RenderSize") var renderSize: RenderSize = .init(width: 1200, height: 2000)
    
    // MARK: - Body
    var body: some View {
        VStack {
            imageArea
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture { focusedField = nil }
            HStack(spacing: 15) {
                shareButton
                Button {
                    withAnimation(.easeInOut) {
                        showConfiguration.toggle()
                    }
                } label: {
                    Label("Params...", systemImage: "pencil")
                }
                Button("Render") { refreshImage() }
            }
            .padding(.bottom, showConfiguration ? 0 : 10)
            .buttonStyle(.bordered)
            configuration
        }
        .padding()
        .animation(.bouncy, value: renderSize)
        .onChange(of: renderSize) {
            withAnimation {
                if showImage {
                    showImage = false
                }
            }
        }
    }
    
    private func refreshImage() {
        withAnimation {
            renderer.renderImage(size: renderSize, blur: Constants.defaultBlur)
            showImage = true
        }
    }
    
    // MARK: - Configuration
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.allowsFloats = false
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    @ViewBuilder
    private var configuration: some View {
        if showConfiguration {
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    TextField("Width", value: $renderSize.width, formatter: formatter)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .width)
                    aspectRatioLock
                    TextField("Height", value: $renderSize.height, formatter: formatter)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .height)
                }
                .textFieldStyle(.roundedBorder)
                .padding(.top, 5)
                HStack {
                    Slider(value: $renderSize.width, in: 500...8000, step: 50)
                    ColorSchemeSwitchButton()
                    Slider(value: $renderSize.height, in: 500...8000, step: 50)
                }
                .onAppear {
                    let config = UIImage.SymbolConfiguration(scale: .small)
                    let thumbImage = UIImage(systemName: "circle.fill",
                                             withConfiguration: config)
                    UISlider.appearance().setThumbImage(thumbImage, for: .normal)
                }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    private var aspectRatioLock: some View {
        Button {
            if lockedAspectRatio != nil {
                lockedAspectRatio = nil
            } else {
                lockedAspectRatio = renderSize.width / renderSize.height
            }
        } label: {
            Image(systemName: "link")
                .tint((lockedAspectRatio != nil) ? .blue : .gray)
        }
        .onChange(of: renderSize.width) {
            if let lockedAspectRatio {
                renderSize.height = renderSize.width / lockedAspectRatio
            }
        }
        .onChange(of: renderSize.height) {
            if let lockedAspectRatio {
                renderSize.width = renderSize.height * lockedAspectRatio
            }
        }
    }
    
    private enum InputField: Hashable {
        case width
        case height
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
            
            let bgColor: UIColor = colorScheme == .dark ? .black : .white
            guard let uiImage else { return nil }
            guard let data = uiImage.jpegData(backgroundColor: bgColor, compressionQuality: Constants.jpegQuality) else {
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
    
    // MARK: - Image Area
    @ViewBuilder
    private var imageArea: some View {
        if !showImage {
            ProportionalRoundedRectangle(cornerFraction: 0.03)
                .stroke(.blue, lineWidth: 5)
                .fill(.blue.opacity(0.1))
                .aspectRatio(renderSize.width / renderSize.height,
                             contentMode: .fit)
                .transition(
                    .move(edge: .top)
                    .combined(with: .opacity)
                )
        } else {
            renderedImage
                .transition(
                    .move(edge: .top)
                    .combined(with: .opacity)
                )
        }
    }
    
    @ViewBuilder
    private var renderedImage: some View {
        switch renderer.renderState {
        case .rendered(let uiImage):
            Image(uiImage: uiImage)
                .resizable()
                .clipShape(ProportionalRoundedRectangle(cornerFraction: 0.03))
                .scaledToFit()
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
    @Previewable @AppStorage("RenderSize") var renderSize: RenderSize = .init(width: 1200, height: 2000)
    let renderer = GradientRenderer(preset: .default)
    RenderPreview()
        .environment(renderer)
        .onAppear {
            renderer.renderImage(size: renderSize)
        }
}
