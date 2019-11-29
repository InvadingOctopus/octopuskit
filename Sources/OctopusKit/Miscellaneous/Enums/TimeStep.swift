//
//  TimeStep.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/28.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// Specifies the timestep for time-dependent components.
public enum TimeStep {
    
    /// Fixed timestep; applies a constant `…perUpdate` change to the affected values in `update(deltaTime:)` every frame.
    ///
    /// Use this when slower gameplay is preferred to losing frames.
    case perFrame
    
    /// Variable timestep; multiples each `…perUpdate` change by `deltaTime` in `update(deltaTime:)` every frame.
    ///
    /// Use this when losing frames is preferred to slower gameplay.
    case perSecond
    
    /// Shorthand for `value += (timestep == .perFrame) ? change : change * deltaTime`
    @inlinable
    public func apply <Number> (_ change:  Number,
                                to value:  inout Number,
                                deltaTime: Number)
        where Number: Numeric
    {
        value += (self == .perFrame) ? change : change * deltaTime
//        switch self {
//        case .perFrame:     value += change
//        case .perSecond:    value += change * deltaTime
//        @unknown default:   fatalError("\(self) case not supported.")
//        }
    }
}

// Prompted by a discussion on the Reddit /r/GameDev Discord. :)
