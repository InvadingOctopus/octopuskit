//
//  Bundle+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020-06-30
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

public extension Bundle {

    /// The bundle containing the assets and resources which are included with OctopusKit.
    ///
    /// **Example:** `Color("OctopusKit/Colors/OKPurple", bundle: Bundle.octopusKit)`
    static var octopusKit: Bundle {
        return Bundle.module
    }
}
