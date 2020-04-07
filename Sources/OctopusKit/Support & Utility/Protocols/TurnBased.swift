//
//  TurnBased.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/04/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// A protocol for objects in a turn-based system.
public protocol TurnBased {
    
    // *Abstract; override in subclass.* Use this to perform any tasks that must occur at the beginning of each turn, *before* `updateTurn(delta:)`, such as health regeneration effects.
    ///
    /// - Parameter turns: The number of turns passed since the previous update.
    func beginTurn(delta turns: Int)
    
    /// *Abstract; override in subclass.*
    /// 
    /// - Parameter turns: The number of turns passed since the previous update.
    func updateTurn(delta turns: Int)
    
    /// *Abstract; override in subclass.* Use this to perform any tasks that must occur at the end of each turn, *after* `updateTurn(delta:)`, such as damage-over-time effects.
    ///
    /// - Parameter turns: The number of turns passed since the previous update.
    func endTurn(delta turns: Int)
}
