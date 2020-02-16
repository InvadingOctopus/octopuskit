//
//  Comparable+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/06.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

public extension Comparable {
    
    // NOTE: An extension to the `Comparable` protocol applies to `Int`, `Float`, `Double`, etc.
    
    /// Returns a value which is equal to this value limited to the specified range.
    @inlinable
    func clamped(to range: ClosedRange<Self>) -> Self {
        // CREDIT: https://stackoverflow.com/a/43769799/1948215
        min(max(self, range.lowerBound), range.upperBound)
    }
    
    /// Limits this value to the specified range.
    @inlinable
    mutating func clamp(to range: ClosedRange<Self>) {
        self = self.clamped(to: range)
    }
}
