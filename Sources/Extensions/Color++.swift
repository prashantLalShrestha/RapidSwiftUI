//
//  Color++.swift
//

import SwiftUI

public extension Color {
    init(hex: String, alpha: CGFloat = 1.0) {
        self.init(.init(hexString: hex, alpha: alpha))
    }
}
