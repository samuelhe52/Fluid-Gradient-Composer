//
//  ContentView.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/8/11.
//

import SwiftUI
import FluidGradient

struct ContentView: View {
    @ObservedObject var configurationStore: FluidGradientConfigurationStore
    
    var body: some View {
        VStack {
            gradient
                .clipShape(RoundedRectangle(cornerRadius: 25))
            HStack {
                Button {
                    configurationStore.randomizeColors()
                } label: { Text("Randomize") }
                Slider(value: $configurationStore.speed, in: 0...5)
                ColorSchemeSwitcher()
            }
            .padding(4)
        }
        .padding()
        .navigationTitle("Fluid Gradient Composer")
    }
    
    var gradient: some View {
        FluidGradient(blobs: configurationStore.colors,
                      highlights: configurationStore.highlights,
                      speed: configurationStore.speed)
    }
}

#Preview {
    ContentView(configurationStore: .init())
}
