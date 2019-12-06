//
//  Equatable.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/02.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

public extension Equatable {
    
    /// - Returns: `true` if the provided list of items contains this object or value.
    @inlinable
    func isAny(of candidates: Self...) -> Bool {
        // CREDIT: https://twitter.com/johnsundell/status/943510426586959873
        // CREDIT: https://github.com/JohnSundell/SwiftTips
        candidates.contains(self)
    }
    
}
