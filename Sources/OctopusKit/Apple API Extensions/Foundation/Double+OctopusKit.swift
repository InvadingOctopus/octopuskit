//
//  Double+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/06.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

extension Double {
    
    // MARK: - Random Numbers
    
    /// Returns a `Double` between 0 to 1.
    ///
    /// Uses `arc4random(_:)`
    public static func unitRandom() -> Double {
        // CREDIT: Apple Adventure Sample
        
        #if swift(>=4.2)
        // TODO: Remove `arc4random` variant after Swift 4.2 is released.
        let quotient = Double(Int.random(in: 0...Int.max)) / Double(Int.max) // CHECK: Is `0...Int.max` the same range as `arc4random()`?
        #else
        let quotient = Double(arc4random()) / Double(UInt32.max)
        #endif
        
        return quotient
    }
    
}
