//
//  NodePointerState.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/4.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// The state of a pointer-based interaction (touch or mouse) in relation to a `SpriteKitComponent` node, as tracked by components which handle player input, such as `NodePointerStateComponent`.
public enum NodePointerState: String, CustomStringConvertible {
    
    // The enum has a `rawValue` of `String` to assist with `description` for `CustomStringConvertible`.
    
    /// The default state, when the node is ready to accept input.
    case ready
    
    /// When the player touches or clicks the node.
    case pointing
    
    /// May occur after a `pointing` state, when the player keeps the finger or mouse pressed after touching or clicking the node, then moves the finger or cursor outside the node's bounds without lifting the finger or mouse button.
    case pointingOutside
    
    /// May occur after a `pointing` state, when the player lifts the finger or mouse button inside the node's bounds.
    ///
    /// - IMPORTANT: This state only persists for a single frame, then the state is immediately set to `ready` on the next frame.
    case tapped // CHECK: Rename to tappedOrClicked?
    
    /// May occur after a `pointing` state, when the player lifts the finger or mouse button *outside* the node's bounds.
    ///
    /// - IMPORTANT: This state only persists for a single frame, then the state is immediately set to `ready` on the next frame.
    case endedOutside
    
    /// When the component is inactive and the node is not accepting input.
    case disabled
    
    public var description: String { return self.rawValue }
}
