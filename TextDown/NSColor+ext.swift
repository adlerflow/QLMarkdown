//
//  NSColor+ext.swift
//  TextDown
//
//  Created by adlerflow on 12/12/20.
//

import Cocoa

extension NSColor {
    convenience init?(css: String?) {
        guard let css = css, !css.isEmpty else {
            return nil
        }
        var color = css.hasPrefix("#") ? String(css.dropFirst()) : css

        // Expand short forms: #RGB → #RRGGBB, #RGBA → #RRGGBBAA
        if color.count == 3 || color.count == 4 {
            var expanded = ""
            for char in color {
                expanded += String(char) + String(char)
            }
            color = expanded
        }

        var rgbValue: UInt64 = 0
        Scanner(string: color).scanHexInt64(&rgbValue)

        let alpha: CGFloat
        if color.count == 8 {
            // #RRGGBBAA format
            alpha = CGFloat((rgbValue & 0xFF)) / 255.0
            rgbValue = rgbValue >> 8
        } else {
            // #RRGGBB format (default alpha = 1.0)
            alpha = 1.0
        }

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    // MARK: - Helper Methods

    private func sRGBNormalizedComponents() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
        guard let color = self.usingColorSpace(NSColorSpace.sRGB) else {
            return nil
        }
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }

    private func toHex(_ value: Int) -> String {
        var hex = String(value, radix: 16, uppercase: true)
        if hex.count == 1 {
            hex = "0\(hex)"
        }
        return hex
    }

    // MARK: - Public API

    func css() -> String? {
        guard let hex = hexComponents() else {
            return nil
        }
        return "#\(hex.r)\(hex.g)\(hex.b)"
    }

    func cssWithAlpha() -> String? {
        guard let hex = hexComponents() else {
            return nil
        }
        return "#\(hex.r)\(hex.g)\(hex.b)\(hex.a)"
    }

    func normalizedComponents() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
        return sRGBNormalizedComponents()
    }

    func rgbComponents() -> (r: Int, g: Int, b: Int, a: Int)? {
        guard let normalized = sRGBNormalizedComponents() else {
            return nil
        }
        let r = Int(round(normalized.r * 255.0))
        let g = Int(round(normalized.g * 255.0))
        let b = Int(round(normalized.b * 255.0))
        let a = Int(round(normalized.a * 255.0))
        return (r, g, b, a)
    }

    func hexComponents() -> (r: String, g: String, b: String, a: String)? {
        guard let rgb = rgbComponents() else {
            return nil
        }
        return (toHex(rgb.r), toHex(rgb.g), toHex(rgb.b), toHex(rgb.a))
    }
}
