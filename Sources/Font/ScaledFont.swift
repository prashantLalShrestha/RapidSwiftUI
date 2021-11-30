//
//  ScaledFont.swift
//

import UIKit
import SwiftUI


struct FontDescription: Decodable {
    let fontName: String
    let fontSize: CGFloat
}

typealias StyleDictionary = [UIFont.TextStyle.RawValue: FontDescription]

private var defaultStyleDictionary: StyleDictionary? = nil
private var defaultFontFamily: String? = nil

private extension UIFont.TextStyle {
    
    var pointSize: CGFloat {
        switch self {
        case .largeTitle: return 34
        case .title1: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        case .body: return 17
        case .callout: return 16
        case .subheadline: return 15
        case .footnote: return 13
        case .caption1: return 12
        case .caption2: return 11
        default: return 17
        }
    }
    
    
    var rawValue: String {
        switch self {
        case .largeTitle: return "largeTitle"
        case .title1: return "title1"
        case .title2: return "title2"
        case .title3: return "title3"
        case .headline: return "headline"
        case .body: return "body"
        case .callout: return "callout"
        case .subheadline: return "subheadline"
        case .footnote: return "footnote"
        case .caption1: return "caption1"
        case .caption2: return "caption2"
        default: return ""
        }
    }
}


public extension UIFont {
    
    class var defaultFontName: String? {
        return defaultFontFamily
    }
    
    class func setDefaultFontFamily(_ name: String) {
        defaultFontFamily = name
    }
    
    internal class var defaultFontStyleDictionary: StyleDictionary? {
        return defaultStyleDictionary
    }
    
    class func setDefaultFontStyle(resourceName: String, bundle: Bundle = .main, withExtension: String = "plist") {
        if let url = bundle.url(forResource: resourceName, withExtension: withExtension),
            let data = try? Data(contentsOf: url) {
            let decoder = PropertyListDecoder()
            defaultStyleDictionary = try? decoder.decode(StyleDictionary.self, from: data)
        }
    }
    
    class func defaultFont(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        let fontName = UIFont.defaultFontName
        let fontSize = textStyle.pointSize
        
        guard let fontName = fontName else {
            return UIFont.preferredFont(forTextStyle: textStyle)
        }
        
        return scaledFont(fontName, size: fontSize, relativeTo: textStyle)
    }
    
    class func defaultStyledFont(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        guard let fontDescription = defaultFontStyleDictionary?[textStyle.rawValue] else {
            return UIFont.defaultFont(forTextStyle: textStyle)
        }
        
        return scaledFont(fontDescription.fontName, size: fontDescription.fontSize, relativeTo: textStyle)
    }
    
    class func scaledFont(_ name: String, size: CGFloat, relativeTo textStyle: UIFont.TextStyle) -> UIFont {
        guard let font = UIFont(name: name, size: size) else {
            return UIFont.preferredFont(forTextStyle: textStyle)
        }
        
        let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
        let scaledFont = fontMetrics.scaledFont(for: font)
        
        switch textStyle {
        case .headline: return scaledFont.withWeight(.semibold)
        default: return scaledFont
        }
    }
    
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]
        
        traits[.weight] = weight
        
        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName
        
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}


@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Font {
    public static var defaultFontFamily: String? {
        return UIFont.defaultFontName
    }
    
    public static func setDefaultFontFamily(_ name: String) {
        UIFont.setDefaultFontFamily(name)
    }
    
    
    internal static var defaultFontStyleDictionary: StyleDictionary? {
        return UIFont.defaultFontStyleDictionary
    }
    
    public static func setDefaultFontStyle(resourceName: String, bundle: Bundle = .main, withExtension: String = "plist") {
        UIFont.setDefaultFontStyle(resourceName: resourceName, bundle: bundle, withExtension: withExtension)
    }
    
    
    public static func `default`(_ textStyle: Font.TextStyle) -> Font {
        let uiTextStyle = uiTextStyle(textStyle)
        var fontName = UIFont.defaultFontName
        var fontSize = uiTextStyle.pointSize
        
        if let fontDescription = defaultFontStyleDictionary?[uiTextStyle.rawValue] {
            fontName = fontDescription.fontName
            fontSize = fontDescription.fontSize
        }
        
        guard let fontName = fontName else {
            return Font.system(textStyle)
        }
        return Font.scaled(fontName, size: fontSize, relativeTo: textStyle)
    }
    
    public static func defaultStyled(_ textStyle: Font.TextStyle) -> Font {
        let uiTextStyle = uiTextStyle(textStyle)
        guard let fontDescription = defaultFontStyleDictionary?[uiTextStyle.rawValue] else {
            return Font.default(textStyle)
        }
        
        return Font.scaled(fontDescription.fontName, size: fontDescription.fontSize, relativeTo: textStyle)
    }
    

    public static func scaled(_ name: String, size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            let font = Font.custom(name, size: size, relativeTo: textStyle)
            switch textStyle {
            case .headline: return font.weight(.semibold)
            default: return font
            }
        } else {
            // Falback to UIKit methods for iOS 13
            return Font(UIFont.defaultFont(forTextStyle: uiTextStyle(textStyle)))
        }
    }

    private static func uiTextStyle(_ textStyle: Font.TextStyle) -> UIFont.TextStyle {
        switch textStyle {
        case .largeTitle: return largeTitle()
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        @unknown default: return .body
        }
    }

    // On tvOS fallback to .title1 text style as
    // UIKit (but not SwiftUI) is missing .largeTitle.
    private static func largeTitle() -> UIFont.TextStyle {
        #if os(tvOS)
            return .title1
        #else
            return .largeTitle
        #endif
    }
}
