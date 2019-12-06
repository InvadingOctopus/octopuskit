//
//  CGFloat+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/06.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import CoreGraphics

public extension CGFloat {
        
    /// Shorthand for `CGFloat(Int.random(in: range))`
    @inlinable
    static func randomInteger(in range: Range<Int>) -> CGFloat {
        CGFloat(Int.random(in: range))
    }
    
    /// Shorthand for `CGFloat(Int.random(in: range))`
    @inlinable
    static func randomInteger(in range: ClosedRange<Int>) -> CGFloat {
        CGFloat(Int.random(in: range))
    }
    
    /// Shorthand for `CGFloat(Int.random(in: range, using: &generator))`
    @inlinable
    static func randomInteger <T> (in range: Range<Int>, using generator: inout T) -> CGFloat
        where T: RandomNumberGenerator
    {
        CGFloat(Int.random(in: range, using: &generator))
    }
    
    /// Shorthand for `CGFloat(Int.random(in: range, using: &generator))`
    @inlinable
    static func randomInteger <T> (in range: ClosedRange<Int>, using generator: inout T) -> CGFloat
        where T: RandomNumberGenerator
    {
        CGFloat(Int.random(in: range, using: &generator))
    }
    
}
