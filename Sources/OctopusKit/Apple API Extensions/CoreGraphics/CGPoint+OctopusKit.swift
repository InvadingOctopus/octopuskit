//
//  CGPoint+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import CoreGraphics
import SpriteKit

public extension CGPoint {
    
    // MARK: - Properties
    
    /// The point with location `(0.5,0.5)`.
    ///
    /// Useful for setting the `anchorPoint` of SpriteKit scenes and sprites at their center.
    @inlinable
    static var half: CGPoint {
        CGPoint(x: 0.5, y: 0.5)
    }
    
    // MARK: - Initializers
    
    /// Converts a `CGVector` to `CGPoint`.
    init(_ vector: CGVector) {
        self.init(x: vector.dx,
                  y: vector.dy)
    }
    
    /// Converts a `SIMD2<Float>` to `CGPoint`.
    init(_ point: SIMD2<Float>) {
        self.init(x: CGFloat(point.x),
                  y: CGFloat(point.y))
    }
    
    // MARK: - Common Tasks
    
    /// Returns the distance between two points.
    @inlinable
    static func distance(between a: CGPoint, and b: CGPoint) -> CGFloat {
        a.distance(to: b)
    }
    
    /// Returns the distance from this point to the specified point.
    @inlinable
    func distance(to otherPoint: CGPoint) -> CGFloat {
        // CREDIT: Apple Adventure Sample and https://developer.apple.com/documentation/spritekit/skaction
        
        // CURIOUS: Does it matter if it's "A - B" or "B - A"? Most examples I've seen write "B - A", why?
        
        hypot(otherPoint.x - self.x,
              otherPoint.y - self.y)
        
        // CHECK: Is there a difference in performance between `hypot` and the `sqrtf` formula?
        // The formula below results in a different value after 7 decimal digits.
        //
        // return CGFloat(sqrtf(
        //    Float(otherPoint.x - self.x) * Float(otherPoint.x - self.x) +
        //        Float(otherPoint.y - self.y) * Float(otherPoint.y - self.y)))
    }
    
    /// Returns a new point with the position of this point limited to a rectangle.
    @inlinable
    func clamped(to rect: CGRect) -> CGPoint {
        var newPoint = self
        switch newPoint.x {
        case let x where x < rect.minX: newPoint.x = rect.minX
        case let x where x > rect.maxX: newPoint.x = rect.maxX
        default: break
        }
        switch newPoint.y {
        case let y where y < rect.minY: newPoint.y = rect.minY
        case let y where y > rect.maxY: newPoint.y = rect.maxY
        default: break
        }
        return newPoint
    }
    
    /// Clamps this point inside a rectangle.
    @inlinable
    mutating func clamp(to rect: CGRect) {
        self = self.clamped(to: rect)
    }
    
    /// Returns a point in the specified direction at the specified distance from the source point.
    @inlinable
    static func point(from source: CGPoint,
                             atAngle radians: CGFloat,
                             distance: CGFloat) -> CGPoint
    {
        source.point(atAngle: radians, distance: distance)
    }
    
    /// Returns a point in the specified direction at the specified distance from this point.
    @inlinable
    func point(atAngle radians: CGFloat,
                      distance: CGFloat) -> CGPoint
    {
        // TODO: Eliminate the possibility of round-off errors, e.g. 9.99999999999999 instead of 10.
        CGPoint(x: self.x + (cos(radians) * distance),
                y: self.y + (sin(radians) * distance))
    }
    
    /// Moves this point in the specified direction for the specified distance.
    @inlinable
    mutating func move(inAngle radians: CGFloat, distance: CGFloat) {
        // ℹ️ DESIGN: CHECK: Duplicating `point(atAngle:distance:)` instead of calling it for the possibility of slightly increased performance when we're moving points around very often.
        // TODO: Eliminate the possibility of round-off errors, e.g. 9.99999999999999 instead of 10.
        self.x += cos(radians) * distance
        self.y += sin(radians) * distance
    }
    
    /// Returns the angle between this point and the specified point.
    @inlinable
    func radians(to point: CGPoint) -> CGFloat {
        // CREDIT: Apple Adventure Sample
        atan2(point.y - self.y,
              point.x - self.x)
    }
    
    // MARK: - Operators
    
    @inlinable
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x + right.x,
                y: left.y + right.y)
    }
    
    @inlinable
    static func += (left: inout CGPoint, right: CGPoint) {
        left.x += right.x
        left.y += right.y
    }
    
    @inlinable
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x - right.x,
                y: left.y - right.y)
    }
    
    @inlinable
    static func -= (left: inout CGPoint, right: CGPoint) {
        left.x -= right.x
        left.y -= right.y
    }
    
    @inlinable
    static func * (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x * right.x,
                y: left.y * right.y)
    }
    
    @inlinable
    static func *= (left: inout CGPoint, right: CGPoint) {
        left.x *= right.x
        left.y *= right.y
    }
    
    @inlinable
    static func / (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x / right.x,
                y: left.y / right.y)
    }
    
    @inlinable
    static func /= (left: inout CGPoint, right: CGPoint) {
        left.x /= right.x
        left.y /= right.y
    }
    
}
