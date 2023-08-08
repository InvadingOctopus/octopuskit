//
//  OctopusKit+Logs.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/12.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  Logs are in a separate extension for convenience, e.g. so that a project may replace them with its own versions.

import OctopusCore
import OSLog

public extension OKLog {
    
    // MARK: Global Game-related Logs
        
    /// A log for transitions within game states and entity states.
    static let states     = Logger(subsystem: OctopusCore.OctopusKit.Constants.Strings.octopusKitBundleID, category: "🚦 States")
    
    /// A log for the components architecture, including entities and component systems.
    static let components = Logger(subsystem: OctopusCore.OctopusKit.Constants.Strings.octopusKitBundleID, category: "🧩 ECS")
        
    /// A log for the cycle of turn updates in a turn-based game.
    static let turns      = Logger(subsystem: OctopusCore.OctopusKit.Constants.Strings.octopusKitBundleID, category: "🔄 Turns")

}
