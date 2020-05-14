//
//  Point.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/14.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation
import SpriteKit

/// A structure that contains a point in a two-dimensional coordinate system, using integer coordinates.
public struct Point: Equatable, Codable {
    
    // TODO: Animatable, CustomReflectable
    // CHECK: CGAffineTransform?
    
    // ℹ️ The `Int` counterpart to `Point`, to avoid tedious casting when using as the coordinates for 2D arrays and tile-maps etc.
    
    public var x, y: Int
    
    /// The point with location `(0,0)`.
    public static var zero = Point(x: 0, y: 0)
    
    /// Creates a point with location `(0,0)`.
    public init() {
        self.x = 0
        self.y = 0
    }
    
    /// Creates a point with coordinates specified as integer values.
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
}

public extension Point {
    
    // TODO: Tests
    
    // ℹ️ DESIGN: These are mostly duplicated from the CGPoint+OctopusKit extensions, instead of creating a single `PointProtocol` that would apply to both `Point` and `CGPoint`, because there were too many exceptions to cover for floating point versus integer operations anyway, such as division.
        
    // MARK: - Initializers
    
    /// Converts a `CGPoint` to `Point`.
    init(_ point: CGPoint) {
        self.init(x: Int(point.x),
                  y: Int(point.y))
    }
    
    /// Converts a `CGVector` to `Point`.
    init(_ vector: CGVector) {
        self.init(x: Int(vector.dx),
                  y: Int(vector.dy))
    }
    
    // MARK: - Common Tasks
    
    /// Returns the distance between two points.
    @inlinable
    static func distance(between a: Point, and b: Point) -> CGFloat {
        a.distance(to: b)
    }
    
    /// Returns the distance from this point to the specified point.
    @inlinable
    func distance(to otherPoint: Point) -> CGFloat {
        // CREDIT: Apple Adventure Sample and https://developer.apple.com/documentation/spritekit/skaction
        
        // CURIOUS: Does it matter if it's "A - B" or "B - A"? Most examples I've seen write "B - A", why?
        
        hypot(CGFloat(otherPoint.x - self.x),
              CGFloat(otherPoint.y - self.y))
        
        // CHECK: Is there a difference in performance between `hypot` and the `sqrtf` formula?
        // The formula below results in a different value after 7 decimal digits.
        //
        // return CGFloat(sqrtf(
        //    Float(otherPoint.x - self.x) * Float(otherPoint.x - self.x) +
        //        Float(otherPoint.y - self.y) * Float(otherPoint.y - self.y)))
    }
    
    /// Returns a new point with the position of this point limited to a rectangle.
    @inlinable
    func clamped(to rect: CGRect) -> Point {
        
        // PERFORMANCE: Do not use `clamp` as ranges might cause unnecessary allocations.
        
        let maxX = Int(rect.maxX)
        let maxY = Int(rect.maxY)
        let minX = Int(rect.minX)
        let minY = Int(rect.minY)
        
        var newPoint = self
        
        switch newPoint.x {
        case let x where x < minX: newPoint.x = minX
        case let x where x > maxX: newPoint.x = maxX
        default: break
        }
        switch newPoint.y {
        case let y where y < minY: newPoint.y = minY
        case let y where y > maxY: newPoint.y = maxY
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
    static func point(from source:     Point,
                      atAngle radians: CGFloat,
                      distance:        CGFloat) -> Point
    {
        source.point(atAngle: radians, distance: distance)
    }
    
    /// Returns a point in the specified direction at the specified distance from this point.
    @inlinable
    func point(atAngle radians: CGFloat,
                      distance: CGFloat) -> Point
    {
        // TODO: Eliminate the possibility of round-off errors, e.g. 9.99999999999999 instead of 10.
        Point(x: self.x + Int(cos(radians) * distance),
              y: self.y + Int(sin(radians) * distance))
    }
    
    /// Moves this point in the specified direction for the specified distance.
    @inlinable
    mutating func move(inAngle radians: CGFloat, distance: CGFloat) {
        // ℹ️ DESIGN: CHECK: Duplicating `point(atAngle:distance:)` instead of calling it for the possibility of slightly increased performance when we're moving points around very often.
        // TODO: Eliminate the possibility of round-off errors, e.g. 9.99999999999999 instead of 10.
        // TODO: Test & verify that this works with integer coordinates.
        self.x += Int(cos(radians) * distance)
        self.y += Int(sin(radians) * distance)
    }
    
    /// Returns the angle between this point and the specified point, where directly east is `0` radians and positive values indicate a counter-clockwise direction.
    @inlinable
    func radians(to point: Point) -> CGFloat {
        // CREDIT: Apple Adventure Sample
        // NOTE: Apparently, `atan2` generally takes Y as the first argument.
        // TODO: Test & verify that this works with integer coordinates.
        atan2(CGFloat(point.y - self.y),
              CGFloat(point.x - self.x))
    }
    
    // MARK: - Operators
    // MARK: Point & Point
    
    @inlinable
    static func + (left: Point, right: Point) -> Point {
        Point(x: left.x + right.x,
              y: left.y + right.y)
    }
    
    @inlinable
    static func += (left: inout Point, right: Point) {
        left.x  += right.x
        left.y  += right.y
    }
    
    @inlinable
    static func - (left: Point, right: Point) -> Point {
        Point(x: left.x - right.x,
              y: left.y - right.y)
    }
    
    @inlinable
    static func -= (left: inout Point, right: Point) {
        left.x  -= right.x
        left.y  -= right.y
    }
    
    @inlinable
    static func * (left: Point, right: Point) -> Point {
        Point(x: left.x * right.x,
              y: left.y * right.y)
    }
    
    @inlinable
    static func *= (left: inout Point, right: Point) {
        left.x  *= right.x
        left.y  *= right.y
    }
    
    @inlinable
    static func / (left: Point, right: Point) -> Point {
        Point(x: left.x / right.x,
              y: left.y / right.y)
    }
    
    @inlinable
    static func /= (left: inout Point, right: Point) {
        left.x  /= right.x
        left.y  /= right.y
    }
    
    // MARK: Point & Int
    
    @inlinable
    static func + (left: Point, right: Int) -> Point {
        Point(x: left.x + right,
              y: left.y + right)
    }
    
    @inlinable
    static func += (left: inout Point, right: Int) {
        left.x  += right
        left.y  += right
    }
    
    @inlinable
    static func - (left: Point, right: Int) -> Point {
        Point(x: left.x - right,
              y: left.y - right)
    }
    
    @inlinable
    static func -= (left: inout Point, right: Int) {
        left.x  -= right
        left.y  -= right
    }
    
    @inlinable
    static func * (left: Point, right: Int) -> Point {
        Point(x: left.x * right,
              y: left.y * right)
    }
    
    @inlinable
    static func *= (left: inout Point, right: Int) {
        left.x  *= right
        left.y  *= right
    }
    
    @inlinable
    static func / (left: Point, right: Int) -> Point {
        Point(x: left.x / right,
              y: left.y / right)
    }
    
    @inlinable
    static func /= (left: inout Point, right: Int) {
        left.x  /= right
        left.y  /= right
    }
}
