//
//  ClockView.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/11/24.
//

import SwiftUI

struct ClockView: View {
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
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(spacing: 0) {
                // Time
                Text(timeFormatter.string(from: context.date))
                    .font(.system(size: 96,
                                  weight: .semibold,
                                  design: .monospaced))
                    .padding(.bottom, 4)
                
                // Date
                Text(dateFormatter.string(from: context.date))
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ClockView()
}
