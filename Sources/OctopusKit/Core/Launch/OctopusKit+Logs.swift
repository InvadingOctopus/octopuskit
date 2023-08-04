//
//  OctopusKit+Logs.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/12.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  Logs are in a separate extension for convenience, e.g. so that a project may replace them with its own versions.

import OctopusCore

public extension OctopusKit {
    
    // MARK: Global Logs
    
    /// A log for core or general engine events.
    static var logForFramework  = OKLog(title: "Framework", prefix: "⚙️")
    
    /// A log for transitions within game states and entity states.
    static var logForStates     = OKLog(title: "States",    prefix: "🚦", suffix: "🚦")
    
    /// A log for the components architecture, including entities and component systems.
    static var logForComponents = OKLog(title: "ECS",       prefix: "🧩", suffix: "🧩")
    
    /// A log for operations that involve loading, downloading, caching and writing game assets and related resources.
    static var logForResources  = OKLog(title: "Resources", prefix: "📦", suffix: "📦")
    
    /// A log for the cycle of turn updates in a turn-based game.
    static var logForTurns      = OKLog(title: "Turns",     prefix: "🔄", suffix: "🔄")
    
    /// A log for deinitializations; when an object is freed from memory.
    static var logForDeinits    = OKLog(title: "Deinits",   prefix: "💀", suffix: "💀")
    
    /// A log for events that may cause unexpected behavior but *do not* prevent continued execution.
    ///
    /// Enabling the `breakpointOnNewEntry` flag will trigger a breakpoint after each new entry, if the `DEBUG` conditional compilation flag is set, allowing you to review the state of the application and resume execution if running within Xcode.
    static var logForWarnings   = OKLog(title: "Warnings",  prefix: "⚠️", suffix: "⚠️", breakpointOnNewEntry: false)
    
    /// A log for severe errors that may prevent continued execution. Adding an entry to this log will raise a `fatalError` and terminate the application.
    static var logForErrors     = OKLog(title: "Errors",    prefix: "🚫", suffix: "🚫", haltApplicationOnNewEntry: true)
    
    /// A log for verbose debugging information.
    static var logForDebug      = OKLog(title: "Debugging", prefix: "🐞")
    
    /// A log for developer tips to assist with fixing warnings and errors.
    static var logForTips       = OKLog(title: "Tips",      prefix: "💡")
}
