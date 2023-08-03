//
//  FloatingPoint+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import Foundation

public extension FloatingPoint {
    
    // MARK: - Random Numbers
    
    /// Shorthand for `Self(Int.random(in: range))`
    @inlinable
    static func randomInteger(in range: Range<Int>) -> Self {
        Self(Int.random(in: range))
    }
    
    /// Shorthand for `Self(Int.random(in: range))`
    @inlinable
    static func randomInteger(in range: ClosedRange<Int>) -> Self {
        Self(Int.random(in: range))
    }
    
    /// Shorthand for `CGFloat(Int.random(in: range, using: &generator))`
    @inlinable
    static func randomInteger <T> (in range: Range<Int>, using generator: inout T) -> Self
        where T: RandomNumberGenerator
    {
        Self(Int.random(in: range, using: &generator))
    }
    
    /// Shorthand for `Self(Int.random(in: range, using: &generator))`
    @inlinable
    static func randomInteger <T> (in range: ClosedRange<Int>, using generator: inout T) -> Self
        where T: RandomNumberGenerator
    {
        Self(Int.random(in: range, using: &generator))
    }
    
    // MARK: - Percentages
    
    /// Returns the specified percentage of `self`.
    @inlinable
    func percent(_ percent: Self) -> Self {
        // TODO: Apply this extension to integers too?
        return self * (percent / 100)
    }
    
    /// Returns `self` percent of the specified `value`.
    ///
    /// **Example:** `10.percent(of: 50)` returns `5`
    @inlinable
    func percent(of value: Self) -> Self {
        // TODO: Apply this extension to integers too?
        return value * (self / 100)
    }

}
