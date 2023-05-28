//
//  OKOperators.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/12/19.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

infix operator ∈: ComparisonPrecedence

/// Membership operator; "is an element of".
/// - Returns: `true` if the right-hand array contains the left-hand value.
@inlinable
public func ∈ <T: Equatable> (left: T, right: any Sequence<T>) -> Bool {
    // CREDIT: https://gist.github.com/AliSoftware
    // CREDIT: https://gist.github.com/JohnSundell/1956ce36b9303eb4bf912da0de9e2844
    return right.contains(left)
}

infix operator ≈: ComparisonPrecedence

/// Approximation operator; "Almost Equal To".
/// - Returns: `true` if the difference between the two floating point values is less than the `leastNormalMagnitude`; a value which compares less than or equal to all positive normal numbers (there may be smaller positive numbers but they are subnormal; represented with less precision than normal numbers.)
@inlinable
public func ≈ <T: FloatingPoint> (left: T, right: T) -> Bool {
    // THANKS: ryanslikesocool#3358@Discord
    // Since we're using `abs`, it doesn't matter if we subtract `left` from `right` or vice versa.
    abs(left - right) < T.leastNormalMagnitude
}
