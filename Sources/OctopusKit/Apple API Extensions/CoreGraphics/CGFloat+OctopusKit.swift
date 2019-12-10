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
    
    /// Treats this value as an angle in radians and returns the radians between it and the specified angle.
    @inlinable
    func deltaBetweenAngle(_ targetAngle: CGFloat) -> Self {
        // CREDIT: https://stackoverflow.com/a/2007279/1948215 by https://stackoverflow.com/users/210964/peter-b
        atan2(sin(targetAngle - self),
              cos(targetAngle - self))
    }
    
    /// Treats this value as an angle in radians and rotates it by the specified amount.
    ///
    /// `0` is right/east and positive values indicate a counter-clockwise rotation.
    @inlinable
    mutating func rotate(towards targetRadians: CGFloat, by rotationAmount: CGFloat) {
        self = self.rotated(towards: targetRadians, by: rotationAmount)
    }
    
    /// Treats this value as an angle in radians and returns an angle that is rotated by the specified amount.
    ///
    /// `0` is right/east and positive values indicate a counter-clockwise rotation.
    @inlinable
    func rotated(towards targetRadians: CGFloat, by rotationAmount: CGFloat) -> Self {
        
        // 💡 See alternative techniques for calculating the rotation at the bottom of this file.
        // TODO: CHECK: PERFORMANCE: Compare with other techniques. This may use two `atan2` calls when used from `PointerControlledRotationComponent`.
        
        // #1: Just snap and exit if we're already aligned or the difference is very small.
        
        guard abs(targetRadians - self) > abs(rotationAmount) else {
            return targetRadians
        }
        
        // #2: Decide the direction to rotate in.
        
        var rotationToApply = self // CHECK: .truncatingRemainder(dividingBy: .pi * 2)
        let delta = self.deltaBetweenAngle(targetRadians)
        
        if  delta > 0 {
            rotationToApply += rotationAmount
        
        } else if delta < 0 {
            rotationToApply -= rotationAmount
        }
        
        // #3: Snap to the target angle if we passed it this frame.
        
        if  abs(delta) < abs(rotationAmount) {
            rotationToApply = targetRadians
        }
        
        // #4: Return the calculated rotation.
        
        return rotationToApply
    }
}

// MARK: - Alternative Rotation Techniques

#if AlternativeImplementation

public extension FloatingPoint {
    
    // ℹ️ Alternative techniques for calculating a rotation.
    // ❕ May be outdated in relation to the APIs used by the active implementation.
    
    /// A variation of the rotation calculation algorithm, using `atan2`.
    @inlinable
    fileprivate func rotatedUsingAtan2(towards targetRadians: CGFloat, by rotationAmount: CGFloat) -> Self {
        
        // TODO: CHECK: PERFORMANCE: Compare with other techniques. This may use two `atan2` calls when used from `PointerControlledRotationComponent`.
        
        // #1: Just snap and exit if we're already aligned or the difference is very small.
        
        guard abs(targetRadians - self) > abs(rotationAmount) else {
            return targetRadians
        }
        
        // #2: Decide the direction to rotate in.
        
        var rotationToApply = self // CHECK: .truncatingRemainder(dividingBy: .pi * 2)
        let delta = self.deltaBetweenAngle(targetRadians)
        
        if  delta > 0 {
            rotationToApply += rotationAmount
        
        } else if delta < 0 {
            rotationToApply -= rotationAmount
        }
        
        // #3: Snap to the target angle if we passed it this frame.
        
        if  abs(delta) < abs(rotationAmount) {
            rotationToApply = targetRadians
        }
        
        // #4: Return the calculated rotation.
        
        return rotationToApply
    }
    
    /// A variation of the rotation calculation algorithm, using a modulo operation.
    @inlinable
    fileprivate func rotatedUsingModulo(towards targetRadians: CGFloat, by rotationAmount: CGFloat) -> Self {
        
        // ❗️ This technique causes a node to "shake" when the target point to rotate towards is stationary and very close.
        
        // #1: Just snap and exit if we're already aligned or the difference is very small.
        
        guard abs(targetRadians - self) > abs(rotationAmount) else {
            return targetRadians
        }
        
        // #2: Decide the closest direction to rotate in.
        // THANKS: TheGreatDuck#9159 @ Reddit /r/GameDev Discord
        
        let a = (targetRadians - self)
        let b = (2 * Self.pi)
        let delta = a - b * floor(a / b) // a modulo b == a - b * floor (a / b) // PERFORMANCE: Should be more efficient than a lot of trigonometry math. Right?
        
        var rotationToApply = self // CHECK: .truncatingRemainder(dividingBy: .pi * 2)
        
        if  delta > .pi {
            rotationToApply -= rotationAmount
        
        } else if delta <= .pi {
            rotationToApply += rotationAmount
        }
        
        // #3: Snap to the target angle if we passed it.
        // CHECK: Confirm that we are snapping after passing, not "jumping" ahead [a frame earlier] when the difference is small enough.
        
        if  abs(targetRadians - rotationToApply) < abs(rotationAmount) {
            rotationToApply = targetRadians
        }
        
        // #6: Return the calculated rotation.
        
        return rotationToApply
    }
    
}

#endif
