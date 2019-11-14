//
//  NodeTouchState.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/17.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// The state of a touch-based interaction in relation to a `SpriteKitComponent` node, as tracked by components which handle player input, such as `NodeTouchStateComponent`.
@available(iOS 13.0, *)
@available(macOS, unavailable, message: "Use NodePointerState")
public enum NodeTouchState: String, CustomStringConvertible {
    
    // CHECK: Should there be a new `cancelled` state that's only set on an actual `touchesCancelled` event?
    
    // The enum has a `rawValue` of `String` to assist with `description` for `CustomStringConvertible`.
    
    /// The default state, when the node is ready to accept input.
    case ready
    
    /// When the player touches the node.
    case touching
    
    /// May occur after a `touching` state, when the player keeps the finger pressed on the screen after touching the node, then moves it outside the node's bounds without lifting the finger.
    case touchingOutside
    
    /// May occur after a `touching` state, when the player lifts the finger from the screen inside the node's bounds.
    ///
    /// - IMPORTANT: This state only persists for a single frame, then the state is immediately set to `ready` on the next frame.
    case tapped
    
    /// May occur after a `touching` state, when the player lifts the finger from the screen *outside* the node's bounds, or when the touch is cancelled for other reasons, such as a system interruption.
    ///
    /// - IMPORTANT: This state only persists for a single frame, then the state is immediately set to `ready` on the next frame.
    case endedOutside // CHECK: Rename to `liftedOutside`?
    
    /// When the component is inactive and the node is not accepting input.
    case disabled
    
    public var description: String { return self.rawValue }
}
