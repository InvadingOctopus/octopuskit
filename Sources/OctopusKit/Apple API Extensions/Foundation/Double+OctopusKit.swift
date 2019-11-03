//
//  Double+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/06.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

public extension Double {
    
    // MARK: - Random Numbers
    
    /// Returns a `Double` between 0 to 1.
    ///
    /// Uses `arc4random(_:)`
    static func unitRandom() -> Double {
        // CREDIT: Apple Adventure Sample
        
        let quotient = Double(Int.random(in: 0...Int.max)) / Double(Int.max) // CHECK: Is `0...Int.max` the same range as `arc4random()`?
        
        return quotient
    }
    
}
