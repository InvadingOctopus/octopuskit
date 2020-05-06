//
//  AcceleratedValue.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/05.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// Represents a scalar with a base value that may increase or decrease by the specified amount per frame or per second.
public struct AcceleratedValue <Number: Numeric & Comparable> {
    
    // TODO: Non-linear acceleration
    
    // DECIDE: Should this be a @propertyWrapper?
    // DESIGN: As of Swift 5.1 2019-12-05, the current property wrapper syntax and synthesis may not be suitable for the intended use cases.
    
    /// The base value.
    public var base:          Number
    
    /// The current value with cumulative `acceleration` applied.
    public var current:       Number
    
    /// The maximum permitted value for `current` including accumulated `acceleration`.
    public var maximum:       Number
    
    /// The minimum permitted value for `current` including accumulated de-`acceleration`.
    public var minimum:       Number
    
    /// The amount to change (or decrease, if negative) the `current` value by on every update.
    public var acceleration:  Number
    
    /// `true` if the `current` value is greater than `minimum` and less than `maximum`.
    @inlinable
    public var isWithinBounds: Bool {
        // CHECK: PERFORMANCE: Should this be set whenever `current` is modified, or is it better to check this only when the bounds are important?
        current > minimum
        && current < maximum
    }
    
    /// - Parameters:
    ///   - base: The base value, without any `acceleration`. Default: `1`
    ///   - current: The initial value to start with. Default: `base`
    ///   - maximum: The upper bound for `current` including accumulated `acceleration`. Default: `base`
    ///   - minimum: The lower bound for `current` including accumulated deceleration, if `acceleration` is a negative amount. Default: `base`
    ///   - acceleration: Specify a negative amount to decelerate. Default: `0`
    public init(base:         Number  = 1,
                current:      Number? = nil,
                maximum:      Number? = nil,
                minimum:      Number? = nil,
                acceleration: Number  = 0)
    {
        self.base    = base
        self.current = current ?? base
        self.maximum = maximum ?? base
        self.minimum = minimum ?? base
        self.acceleration = acceleration
    }
    
    /// Adds `acceleration` to the `current` value. Does *not* check for `minimum` or `maximum`; call `clamp()` to limit the value within those bounds.
    ///
    /// - Returns: `self` which may then be chained with `.clamp()`.
    @inlinable
    public mutating func update() {
        current += acceleration
    }
    
    /// Adds `acceleration` × `deltaTime` to the `current` value. Does *not* check for `minimum` or `maximum`; call `clamp()` to limit the value within those bounds.
    ///
    /// - Returns: `self` which may then be chained with `.clamp()`.
    @inlinable
    public mutating func update(deltaTime: Number) {
        current += acceleration * deltaTime
    }
    
    /// Applies `acceleration` to the `current` value, scaling `acceleration` by `deltaTime` if `timeStep` is `perSecond`.Does *not* check for `minimum` or `maximum`; call `clamp()` to limit the value within those bounds.
    @inlinable
    public mutating func update(timeStep: TimeStep, deltaTime: Number) {
        timeStep.apply(acceleration, to: &current, deltaTime: deltaTime)
    }
    
    /// If `current` is less than `minimum`, sets it to `minimum`, or if `current` is greater than `maximum`, sets it to `maximum` (checked in that order.)
    @inlinable
    public mutating func clamp() {
        if  current < minimum {
            current = minimum
        } else if current > maximum {
            current = maximum
        }
    }
    
    /// Sets `current` to `base`.
    @inlinable
    public mutating func reset() {
        current = base
    }
    
}
