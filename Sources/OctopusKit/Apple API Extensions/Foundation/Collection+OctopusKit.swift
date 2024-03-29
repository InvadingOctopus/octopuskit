//
//  Collection+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/03.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation



// MARK: - Randomization
// Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.

import GameplayKit

public extension Collection where Index == Int {
        
    
    /// Returns a random element from this array whose index is not in `skippingIndices` and generated by the `randomDistribution` source provided..
    ///
    /// If the array is empty or if the list of exclusions prevents any acceptable value within `maximumAttempts`, `nil` is returned.
    ///
    /// If the array has only 1 element, then that is returned without generating any random indices.
    ///
    /// Can be used with array literals, e.g.: `[4, 8, 16, 42].randomElement(usingDistribution: GKRandomDistribution.d20(), skippingIndices: [0, 1, 2])`
    @inlinable
    func randomElement(usingDistribution randomDistribution: GKRandomDistribution,
                       skippingIndices exclusions: Set<Int>? = nil,
                       maximumAttempts: UInt = 100) -> Element?
    {
        guard self.count > 0 else { return nil }
        guard self.count > 1 else { return self[0] }
        
        var randomIndex: Int?
        
        if  let exclusions = exclusions {
            randomIndex = randomDistribution.nextInt(upperBound: self.count,
                                                     skipping: exclusions,
                                                     maximumAttempts: maximumAttempts)
        } else {
            randomIndex = randomDistribution.nextInt(upperBound: self.count)
        }
        
        if  let randomIndex = randomIndex {
            return self[randomIndex]
        } else {
            return nil
        }
    }
}
