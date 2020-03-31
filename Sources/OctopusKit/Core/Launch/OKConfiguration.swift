//
//  OKConfiguration.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017-06-05
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

public struct OKConfiguration {
    
    #if os(macOS)
    
    /// If `true` (default), the application's default menu bar is modified to have menu names and items suitable for games.
    ///
    /// This setting is read when `OKViewController` presents its view.
    public var modifyDefaultMenuBar: Bool = true
    
    #endif
    
}
