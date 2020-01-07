//
//  OctopusKit+Logs.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/12.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  Logs are in a separate extension for convenience, e.g. so that a project may replace them with its own versions.

extension OctopusKit {
    
    // MARK: Global Logs
    
    /// A log for core or general engine events.
    public static var logForFramework   = OKLog(title: "🐙")
    
    /// A log for transitions within game states and entity states.
    public static var logForStates      = OKLog(title: "🐙🚦", suffix: "🚦")
    
    /// A log for the components architecture, including entities and component systems.
    public static var logForComponents  = OKLog(title: "🐙🧩", suffix: "🧩")
    
    /// A log for operations that involve loading, downloading, caching and writing game assets and related resources.
    public static var logForResources   = OKLog(title: "🐙📦", suffix: "📦")
    
    /// A log for deinitializations; when an object is freed from memory.
    public static var logForDeinits     = OKLog(title: "🐙💀", suffix: "💀")
    
    /// A log for events that may cause unexpected behavior but do not prevent the continued execution of the game.
    public static var logForWarnings    = OKLog(title: "🐙⚠️", suffix: "⚠️")
    
    /// A log for severe, unexpected events that may prevent the continued execution of the game.
    ///
    /// - Warning: Adding an entry to this log will raise a `fatalError` that terminates the application.
    public static var logForErrors      = OKLog(title: "🐙🚫", suffix: "🚫", haltApplicationOnNewEntry: true)
    
    /// A log for verbose debugging information.
    public static var logForDebug       = OKLog(title: "🐙🐞")
    
    /// A log for developer tips to assist with fixing warnings and errors.
    public static var logForTips        = OKLog(title: "🐙💡")
}
