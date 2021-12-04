//
//  ShapeView.swift
//

import SwiftUI


public struct ShapeView: Shape {
    public let bezier: UIBezierPath
    public let pathBounds: CGRect
    
    public init(bezierPath: UIBezierPath, pathBounds: CGRect) {
        self.bezier = bezierPath
        self.pathBounds = pathBounds
    }
    
    public func path(in rect: CGRect) -> Path {
        let pointScale = (rect.width >= rect.height) ?
        max(pathBounds.height, pathBounds.width) :
        min(pathBounds.height, pathBounds.width)
        let pointTransform = CGAffineTransform(scaleX: 1/pointScale, y: 1/pointScale)
        let path = Path(bezier.cgPath).applying(pointTransform)
        let multiplier = min(rect.width, rect.height)
        let transform = CGAffineTransform(scaleX: multiplier, y: multiplier)
        return path.applying(transform)
    }
}
