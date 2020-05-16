//
//  CGRect+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import CoreGraphics

public extension CGRect {
    
    // MARK: - Initializers
    
    /// Convenience initializer for using an existing `CGPoint` as the origin and customizing the dimensions.
    init(origin:    CGPoint,
         width:     CGFloat,
         height:    CGFloat)
    {
        self.init(x:        origin.x,
                  y:        origin.y,
                  width:    width,
                  height:   height)
    }

    /// Convenience initializer for using an existing `CGSize` for the dimensions and customizing the origin.
    init(x:         CGFloat,
         y:         CGFloat,
         size:      CGSize)
    {
        self.init(x:        x,
                  y:        y,
                  width:    size.width,
                  height:   size.height)
    }

    // MARK: - Properties
    
    /// Returns a point at the rectangle's `midX` and `midY`.
    @inlinable
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    
    /// Returns the point at the corner opposite to `origin`, at `(x: size.width, y: size.height)` if the origin is `(0,0)`, regardless of negative dimensions or transformations.
    @inlinable
    var end: CGPoint {
        // CHECK: Should this be named `tail`?
        // ❕ NOTE: CGRect.size.height or width is different from CGRect.height or width:
        // "Regardless of whether the height/width is stored in the CGRect data structure as a positive or negative number, this function returns the height/width as if the rectangle were standardized. That is, the result is never a negative number."
        // https://developer.apple.com/documentation/coregraphics/cgrect/1455645-height
        CGPoint(x: self.origin.x + self.size.width,
                y: self.origin.y + self.size.height)
    }
    
    /// Returns a new rectangle with the same size as this rectangle, but with an origin of `(0,0)`.
    @inlinable
    var withZeroOrigin: CGRect {
        CGRect(origin: CGPoint.zero, size: self.size)
    }
    
    // MARK: - Common Tasks
    
    /// Returns a new rectangle that is equivalent to this rectangle scaled by the specified factors.
    @inlinable
    func scaled(byX xScale: CGFloat, y yScale: CGFloat) -> CGRect {
        // CHECK: Use `applying(_:)` and `CGAffineTransform(scaleX:y:)`, or is this more efficient?
        CGRect(x: self.origin.x,
               y: self.origin.y,
               width:  self.width  * xScale,
               height: self.height * yScale)
    }
    
    /// Scales this rectangle by the specified factors.
    @inlinable
    mutating func scale(byX xScale: CGFloat, y yScale: CGFloat) {
        self = self.scaled(byX: xScale, y: yScale)
    }
    
}
