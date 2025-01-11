//
//  ProportionalRoundedRectangle.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2025/1/12.
//

import SwiftUI

struct ProportionalRoundedRectangle: Shape {
    var cornerFraction: CGFloat = 0.05
    
    func path(in rect: CGRect) -> Path {
        let minSize = min(rect.width, rect.height)
        let cornerSize = min(0.5, max(0, cornerFraction)) * minSize
        return Path(
            roundedRect: rect,
            cornerSize: .init(width: cornerSize, height: cornerSize)
        )
    }
}

#Preview {
    VStack {
        ProportionalRoundedRectangle(cornerFraction: 0.1)
            .stroke(.blue, lineWidth: 3)
            .frame(width: 200, height: 100)
        ProportionalRoundedRectangle(cornerFraction: 0.25)
            .stroke(.red, lineWidth: 3)
            .frame(width: 300, height: 400)
            .overlay {
                ProportionalRoundedRectangle(cornerFraction: 0.4)
                    .fill(.green)
                    .padding()
            }
    }
}
