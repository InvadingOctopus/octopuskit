//
//  GKRandom+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)

// TODO: Tests

import GameplayKit

public extension GKRandom {
    
    /// Returns a random integer from `INT32_MIN` to `INT32_MAX` or `upperBound-1` if specified (**not** including `upperBound`) that does not match any of the numbers provided in the exclusion list.
    ///
    /// This method repeatedly generates a random number until it finds a number that is not in the exclusions list. If no acceptable number can be generated in `maximumAttempts` then `nil` will returned.
    @inlinable
    func nextInt(upperBound: Int? = nil,
                        skipping exclusions: Set<Int>,
                        maximumAttempts: UInt = 100) -> Int?
    {
        let maximumAttemptsWarningThreshold = 100
        
        if maximumAttempts > maximumAttemptsWarningThreshold {
            OctopusKit.logForWarnings.add("`maximumAttempts` may be too high: \(maximumAttempts) (warning threshold: \(maximumAttemptsWarningThreshold)")
        }
        
        var randomNumber: Int
        var attempts = 0

        // If there are no exclusions, just return the first random number generated.
        
        if exclusions.isEmpty {
            if let upperBound = upperBound {
                return self.nextInt(upperBound: upperBound)
            }
            else {
                return self.nextInt()
            }
        }
        
        // Keep generating random numbers until we find one that's not in the exclusions list, or we've made the maximum number of attempts, so that we don't get stuck in an infinite loop.
        
        repeat {
            
            if let upperBound = upperBound {
                randomNumber = self.nextInt(upperBound: upperBound)
            }
            else {
                randomNumber = self.nextInt()
            }
            
            attempts += 1
            
        } while exclusions.contains(randomNumber) && attempts < maximumAttempts
        
        if !exclusions.contains(randomNumber) {
            return randomNumber
        }
        else {
            OctopusKit.logForWarnings.add("Could not generate any number that is not in `exclusions` (count: \(exclusions.count)) in \(attempts) attempts.")
            return nil
        }
    }
    
}
