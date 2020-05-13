//
//  Point.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/14.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// A structure that contains a point in a two-dimensional coordinate system, using integer coordinates.
public struct Point: Equatable, Codable {
    
    // TODO: Animatable, CustomReflectable
    // CHECK: CGAffineTransform?
    
    // ℹ️ The `Int` counterpart to `CGPoint`, to avoid tedious casting when using as the coordinates for 2D arrays and tile-maps etc.
    
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
