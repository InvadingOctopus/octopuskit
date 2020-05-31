//
//  Equatable.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/02.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

public extension Equatable {
    
    /// Returns `true` if the provided list of items contains this object or value.
    ///
    /// - IMPORTANT: Passing an array is **not** equivalent to a variadic argument; `isAny(of: [1, 2, 3]) != isAny(of: 1, 2, 3)`.
    @inlinable
    func isAny(of candidates: Self...) -> Bool {
        // CREDIT: https://twitter.com/johnsundell/status/943510426586959873
        // CREDIT: https://github.com/JohnSundell/SwiftTips
        candidates.contains(self)
    }
    
}
