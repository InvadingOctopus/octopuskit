//
//  OKOperators.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/12/19.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

infix operator ∈: ComparisonPrecedence

/// Returns `true` if the right-hand array contains the left-hand value.
@inlinable
public func ∈ <T: Equatable> (left: T, right: [T]) -> Bool {
    // CREDIT: https://gist.github.com/AliSoftware
    // CREDIT: https://gist.github.com/JohnSundell/1956ce36b9303eb4bf912da0de9e2844
    return right.contains(left)
}

