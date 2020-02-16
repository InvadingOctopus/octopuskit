//
//  CGFloat+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/06.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import CoreGraphics

public extension CGFloat {
        
    // MARK: Common Angles
    // NOTE: Cannot add these as an extension to FloatingPoint because "Static stored properties not supported in protocol extensions" :(
    
    static let east         =  Self.zero
    static let northEast    =  Self.pi / 4
    static let north        =  Self.pi / 2
    static let northWest    =  Self.pi - (Self.pi / 4)
    static let west         =  Self.pi
    static let southWest    =  Self.pi + (Self.pi / 4)
    static let south        =  Self.pi + (Self.pi / 2)
    static let southEast    = (Self.pi * 2) - (Self.pi / 2)
    
    // MARK: - Trigonometry
    
    /// Treats this value as an angle in radians and returns the radians between it and the specified angle.
    @inlinable
    func deltaBetweenAngle(_ targetAngle: CGFloat) -> CGFloat {
        // CREDIT: https://stackoverflow.com/a/2007279/1948215 by https://stackoverflow.com/users/210964/peter-b
        // NOTE: Cannot add this as an extension to FloatingPoint because atan2 only works on specific types :(
        atan2(sin(targetAngle - self),
              cos(targetAngle - self))
    }
    
    /// Treats this value as an angle in radians and rotates it by the specified amount.
    ///
    /// `0` is right/east and positive values indicate a counter-clockwise rotation.
    @inlinable
    mutating func rotate(towards targetRadians: Self, by rotationAmount: Self) {
        self = self.rotated(towards: targetRadians, by: rotationAmount)
    }
    
    /// Treats this value as an angle in radians and returns an angle that is rotated by the specified amount.
    ///
    /// `0` is right/east and positive values indicate a counter-clockwise rotation.
    @inlinable
    func rotated(towards targetRadians: Self, by rotationAmount: Self) -> Self {
        
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

public extension CGFloat {
    
    // ℹ️ Alternative techniques for calculating a rotation.
    // ❕ May be outdated in relation to the APIs used by the active implementation.
    
    /// A variation of the rotation calculation algorithm, using `atan2`.
    @inlinable
    fileprivate func rotatedUsingAtan2(towards targetRadians: Self, by rotationAmount: Self) -> Self {
        
        // NOTE: Cannot add this as an extension to FloatingPoint because atan2 only works on specific types :(
        
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
    fileprivate func rotatedUsingModulo(towards targetRadians: Self, by rotationAmount: Self) -> Self {
        
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
