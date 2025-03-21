//
//  Extensions.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/12/7.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI
import UIKit

extension UTType {
    static let fgcpreset = UTType(exportedAs: "com.samuelhe.fgcpreset")
    static let fgcconfig = UTType(exportedAs: "com.samuelhe.fgcconfig")
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    func toHex() -> String? {
            let uic = UIColor(self)
            guard let components = uic.cgColor.components, components.count >= 3 else {
                return nil
            }
            let r = Float(components[0])
            let g = Float(components[1])
            let b = Float(components[2])
            var a = Float(1.0)

            if components.count >= 4 {
                a = Float(components[3])
            }

            if a != Float(1.0) {
                return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
            } else {
                return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
            }
        }
}

extension UIImage {
    func jpegData(backgroundColor: UIColor, compressionQuality: CGFloat) -> Data? {
        // Create a context that composites the image over the given background
        UIGraphicsBeginImageContextWithOptions(size, false, scale) // `false` preserves transparency blending
        defer { UIGraphicsEndImageContext() }
        
        let rect = CGRect(origin: .zero, size: size)
        backgroundColor.setFill()
        UIRectFill(rect) // Fill background
        
        draw(in: rect) // Overlay original image
        
        guard let filledImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        return filledImage.jpegData(compressionQuality: compressionQuality)
    }
}

