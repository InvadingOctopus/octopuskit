//
//  Int+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/06.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import Foundation

public extension Int {

    // MARK: - Random Numbers
    
    /// Returns a random integer from `0` to `upperBound-1` (**not** including `upperBound`) that does not match any of the numbers provided in the exclusion list.
    ///
    /// This method repeatedly calls the random number generator until it returns a number that is not in the exclusions list. If no acceptable number can be generated in `maximumAttempts` then `nil` will returned.
    ///
    /// If `upperBound` is less than `0` then `nil` will returned. If `upperBound` is `0` then `0` will be returned without calling the random number generator.
    ///
    /// Uses `arc4random_uniform(_:)`. For GameplayKit-based randomization, use the extensions of `GKRandom`.
    @inlinable
    static func randomFromZero(to upperBound:       Int,
                               skipping exclusions: Set<Int>,
                               maximumAttempts:     UInt = 100) -> Int?
    {
        guard upperBound >= 0 else { return nil }
        if upperBound == 0 { return 0 }
        
        let maximumAttemptsWarningThreshold = 100
        
        // First of all, try to check that the `exclusions` list does not prevent every number that could possibly be generated during this call.
        // Since the `exclusions` list is a `Set`, which prevents repeated values, if the count of elements in the set is same as `max`, then it MAY mean that any possible number is inacceptable! However, the exclusion list may also have values below `0` or above `max`, but checking for every possible value in the entire range may be too inefficient, so we'll just compare the two arguments and log a warning.
        
        if  exclusions.count == upperBound {
            OctopusKit.logForWarnings.add("`exclusions` set has \(upperBound) values — Make sure it does not prevent every possible number within 0..<\(upperBound)")
        }
        
        if  maximumAttempts > maximumAttemptsWarningThreshold {
            OctopusKit.logForWarnings.add("`maximumAttempts` may be too high: \(maximumAttempts) (warning threshold: \(maximumAttemptsWarningThreshold)")
        }
        
        // If there are no exclusions, just return the first random number generated.
        
        if  exclusions.isEmpty {
            return self.random(in: 0 ..< upperBound)
        
        }else {
            var randomNumber: Int
            var attempts = 0
            
            // Keep generating random numbers until we find one that's not in the exclusions list, or we've made the maximum number of attempts, so that we don't get stuck in an infinite loop.
            
            repeat {
                randomNumber = self.random(in: 0 ..< upperBound)
                attempts += 1
                
            } while exclusions.contains(randomNumber)
                 && attempts < maximumAttempts
            
            if !exclusions.contains(randomNumber) {
                return randomNumber
            } else {
                OctopusKit.logForWarnings.add("Could not generate any number that is not in `exclusions` (count: \(exclusions.count)) in \(attempts) attempts.")
                return nil
            }
        }
    }
}
