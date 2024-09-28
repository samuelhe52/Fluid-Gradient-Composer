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
    
    @State private var editingColorIndex: Int?
    
    var body: some View {
        Group {
            LazyHGrid(rows: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(colors.indices, id: \.self) { index in
                    EditableColorBlob(color: $colors[index])
                }
            }
            Button("Randomize") {
                withAnimation {
                    randomizeColors()
                }
            }
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
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack {
                    ForEach(Preset.BuiltinColor.allCases, id: \.self) { optionColor in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(optionColor.displayColor)
                            .frame(width: 40, height: 40)
                            .onTapGesture {
                                color = optionColor
                            }
                            .overlay {
                                Image(systemName: "checkmark")
                                    .opacity(optionColor == color ? 1 : 0)
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
