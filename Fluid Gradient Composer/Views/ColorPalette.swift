//
//  ColorPalette.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/9/28.
//

import SwiftUI

struct ColorPalette: View {
    @Binding var colors: [Preset.BuiltinColor]
    var randomizeColors: () -> Void
        
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: [GridItem(.adaptive(minimum: 40))]) {
                NewColor { colors.insert($0, at: 0) }
                ForEach(colors.indices, id: \.self) { index in
                    EditableColorBlob(color: $colors[index])
                        .overlay {
                            removeSign
                                .onTapGesture {
                                    colors.remove(at: index)
                                }
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
        .animation(.interactiveSpring(duration: 0.15), value: colors)
        Button("Randomize") { randomizeColors() }
    }
    
    private var removeSign: some View {
        Image(systemName: "minus.circle.fill")
            .font(.title3)
            .foregroundStyle(.regularMaterial)
            .offset(x: -15, y: -15)
    }
}

struct NewColor: View {
    @State private var isEditing: Bool = false
    @State private var color: Preset.BuiltinColor = .blue
    
    var set: (Preset.BuiltinColor) -> Void
    
    var body: some View {
        Image(systemName: "plus.app")
            .foregroundStyle(.blue)
            .font(.system(size: 43))
            .popover(isPresented: $isEditing) {
                ColorChooser(color: $color)
            }
            .onTapGesture {
                isEditing = true
            }
            .onChange(of: color) {
                set(color)
            }
    }
}

struct EditableColorBlob: View {
    @Binding var color: Preset.BuiltinColor
    @State private var isEditing: Bool = false
    
    var body: some View {
        ColorBlob(color: color)
            .popover(isPresented: $isEditing) {
                ColorChooser(color: $color)
            }
            .onTapGesture { isEditing = true }
    }
    
}

struct ColorBlob: View {
    var color: Preset.BuiltinColor
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(color.displayColor)
            .frame(width: 40, height: 40)
    }
}

struct ColorChooser: View {
    @Binding var color: Preset.BuiltinColor
    
    @State var usingCustomColor: Bool = false
    @State var customColor: Color = .white
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack {
                    ColorPicker("", selection: $customColor, supportsOpacity: false)
                        .onChange(of: customColor) {
                            usingCustomColor = true
                        }
                        .onDisappear {
                            if customColor != .clear && usingCustomColor {
                                color = .custom(customColor.toHex() ?? "")
                            }
                        }
                        .padding(.trailing)
                    ForEach(Preset.BuiltinColor.allCases, id: \.self) { optionColor in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(optionColor.displayColor)
                            .frame(width: 40, height: 40)
                            .onTapGesture {
                                usingCustomColor = false
                                color = optionColor
                            }
                            .overlay {
                                Image(systemName: "checkmark")
                                    .opacity((optionColor == color && !usingCustomColor) ? 1 : 0)
                            }
                            .id(optionColor)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding()
            .presentationCompactAdaptation(horizontal: .popover, vertical: .popover)
            .onAppear { proxy.scrollTo(color) }
        }
    }
}

#Preview {
    @Previewable @State var colors = Preset.defaultColors
    ColorPalette(colors: $colors) {
        colors = Preset.generateRandomColors().colors
    }
}
