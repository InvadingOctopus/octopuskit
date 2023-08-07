//
//  GKRandom+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)

// TODO: Tests

import OctopusCore
import GameplayKit

public extension GKRandom {
    
    /// Returns a random integer from `INT32_MIN` to `INT32_MAX` or `upperBound-1` if specified (**not** including `upperBound`) that does not match any of the numbers provided in the exclusion list.
    ///
    /// This method repeatedly generates a random number until it finds a number that is not in the exclusions list. If no acceptable number can be generated in `maximumAttempts` then `nil` will returned.
    @inlinable
    func nextInt(upperBound:            Int? = nil,
                 skipping exclusions:   Set<Int>,
                 maximumAttempts:       UInt = 50) -> Int?
    {
        let maximumAttemptsWarningThreshold = 100
        
        if  maximumAttempts > maximumAttemptsWarningThreshold {
            OKLog.logForWarnings.debug("`maximumAttempts` may be too high: \(maximumAttempts) (warning threshold: \(maximumAttemptsWarningThreshold)")
        }
        
        var randomNumber: Int
        var attempts = 0

        // If there are no exclusions, just return the first random number generated.
        
        if  exclusions.isEmpty {
            if  let upperBound = upperBound {
                return self.nextInt(upperBound: upperBound)
            } else {
                return self.nextInt()
            }
        }
        
        // Keep generating random numbers until we find one that's not in the exclusions list, or we've made the maximum number of attempts, so that we don't get stuck in an infinite loop.
        
        repeat {
            
            if  let upperBound = upperBound {
                randomNumber = self.nextInt(upperBound: upperBound)
            } else {
                randomNumber = self.nextInt()
            }
            
            attempts += 1
            
        } while exclusions.contains(randomNumber) && attempts < maximumAttempts
        
        if !exclusions.contains(randomNumber) {
            return randomNumber
        } else {
            OKLog.logForWarnings.debug("Could not generate any number that is not in `exclusions` (count: \(exclusions.count)) in \(attempts) attempts.")
            return nil
        }
    }
}

extension GKRandomSource: RandomNumberGenerator {
  
    // ⚠️ WARNING: GKRandomDistribution does not currently work when accessed as a RandomNumberGenerator

    // GKRandomSource and GKRandomDistribution etc. *should* have implicit conformance to the RandomNumberGenerator protocol, but apparently Apple forgot about GameplayKit when they added it to Swift :(
    
    /// - Returns: An unsigned 64-bit random value.
    public func next() -> UInt64 {
        // CREDIT: Grigory Entin https://stackoverflow.com/users/1859783/grigory-entin
        // https://stackoverflow.com/a/57370987/1948215
        // GKRandom produces values in the `INT32_MIN...INT32_MAX` range; hence we need two numbers to produce 64-bit value.
        let next1 = UInt64(bitPattern: Int64(self.nextInt()))
        let next2 = UInt64(bitPattern: Int64(self.nextInt()))
        return next1 ^ (next2 << 32)
    }
    
    /*
     /// - Returns - A random value of T in the range 0..<upperBound. Every value in the range 0..<upperBound is equally likely to be returned.
     public func next<T>(upperBound: T) -> T
        where T: FixedWidthInteger, T: UnsignedInteger
     {
        return T(abs(self.nextInt(upperBound: Int(upperBound))))
     }
     */ // Causes infinite recursion and a stack overflow, in Swift 5.2 as of 2020-04-22.
}

/*
extension GKRandomDistribution: RandomNumberGenerator {
    // TODO
}
*/
