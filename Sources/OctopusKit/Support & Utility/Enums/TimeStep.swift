//
//  TimeStep.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// Specifies the time step for time-dependent components.
public enum TimeStep {
    
    // CHECK: Add "Between frame" updates?
    // http://expiredpopsicle.com/2014/09/16/Variable_Timesteps_and_Holy_Crap_Math_is_Hard.html
    // http://expiredpopsicle.com/2014/09/18/Tick_Time_Debt.html
    
    /// Fixed time step; applies a constant `…perUpdate` change to the affected values in `update(deltaTime:)` every frame.
    ///
    /// Use this when slower gameplay is preferred to losing frames.
    case perFrame
    
    /// Variable time step; multiples each `…perUpdate` change by `deltaTime` in `update(deltaTime:)` every frame.
    ///
    /// Use this when losing frames is preferred to slower gameplay.
    case perSecond
    
    /// Shorthand for `(timeStep == .perFrame) ? change : change * deltaTime`
    ///
    /// **Example:** `let acceleratedMagnitude = timeStep.applying(acceleration, deltaTime: CGFloat(seconds))`
    ///
    /// - Returns: `change` if the time step is `perFrame`, or `change * deltaTime` if the time step is `perSecond`.
    @inlinable
    public func applying <Number> (_ change:  Number,
                                   deltaTime: Number) -> Number
        where Number: Numeric
    {
        return (self == .perFrame) ? change : change * deltaTime
    }
    
    /// Shorthand for `value += (timeStep == .perFrame) ? change : change * deltaTime`
    ///
    /// **Example:** `timeStep.apply(acceleration, to: &acceleratedMagnitude, deltaTime: CGFloat(seconds))`
    @inlinable
    public func apply <Number> (_ change:  Number,
                                to value:  inout Number,
                                deltaTime: Number)
        where Number: Numeric
    {
        value += (self == .perFrame) ? change : change * deltaTime
    }
    
}

// Prompted by a discussion on the Reddit /r/GameDev Discord. :)
