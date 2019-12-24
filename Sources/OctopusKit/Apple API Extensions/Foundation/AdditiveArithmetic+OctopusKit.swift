//
//  AdditiveArithmetic+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/24.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import Foundation

public extension AdditiveArithmetic where Self: Comparable {
    
    /// Returns a copy of `self` that is closer to the `target` by the specified `amount`.
    ///
    /// May be used for cases like braking an object's velocity towards zero, for example.
    @inlinable
    func adjustedTowards(_ target: Self, by amount: Self) -> Self {
        
        var adjustedValue = self
        
        if  adjustedValue >  target {
            adjustedValue -= amount
            // Correct any overshoot.
            if  adjustedValue < target {
                adjustedValue = target
            }
            return adjustedValue // No need to compare < now.
        }
        
        if  adjustedValue <  target {
            adjustedValue += amount
            // Correct any overshoot.
            if  adjustedValue > target {
                adjustedValue = target
            }
        }
        
        return adjustedValue
    }
    
    /// Changes `self` by the specified `amount` to bring it closer to the `target`.
    ///
    /// May be used for cases like braking an object's velocity towards zero, for example.
    @inlinable
    mutating func adjustTowards(_ target: Self, by amount: Self) {
        self = self.adjustedTowards(target, by: amount)
    }
}
