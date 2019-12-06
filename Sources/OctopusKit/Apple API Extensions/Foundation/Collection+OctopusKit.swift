//
//  Collection+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/03.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

public extension Collection {
    
    @inlinable
    func apply<T>(_ transform: (Self) -> T) -> T {
        // CREDIT: Rudolf Adamkovič (salutis), https://forums.swift.org/t/add-function-application-to-swifts-standard-library/12361
        return transform(self)
    }
    
}
