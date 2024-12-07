//
//  ClockView.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/11/24.
//

import SwiftUI

struct ClockView: View {
    @State private var currentTime = Date()
    
    let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Time
            Text(timeFormatter.string(from: currentTime))
                .font(.system(size: 96,
                              weight: .semibold,
                              design: .monospaced))
                .padding(.bottom, 4)
            
            // Date
            Text(dateFormatter.string(from: currentTime))
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(.secondary)
        }
        .onReceive(timer) { input in
            currentTime = input
        }
    }
}

#Preview {
    ClockView()
}
