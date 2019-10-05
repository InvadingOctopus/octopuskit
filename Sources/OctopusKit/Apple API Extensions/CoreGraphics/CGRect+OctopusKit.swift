//
//  CGRect+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import CoreGraphics

extension CGRect {
    
    /// Returns a point at the rectangle's `midX` and `midY`.
    public var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    /// Returns a new rectangle with the same size as this rectangle, but with an origin of `(0,0)`.
    public var withZeroOrigin: CGRect {
        return CGRect(origin: CGPoint.zero, size: self.size)
    }
    
    /// Returns a new rectangle that is equivalent to this rectangle scaled by the specified factors.
    public func scaled(byX xScale: CGFloat, y yScale: CGFloat) -> CGRect {
        // CHECK: Use `applying(_:)` and `CGAffineTransform(scaleX:y:)`, or is this more efficient?
        return CGRect(
            x: self.origin.x,
            y: self.origin.y,
            width: self.width * xScale,
            height: self.height * yScale)
    }
    
    /// Scales this rectangle by the specified factors.
    public mutating func scale(byX xScale: CGFloat, y yScale: CGFloat) {
        self = self.scaled(byX: xScale, y: yScale)
    }
    
}
