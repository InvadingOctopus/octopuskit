//
//  SKView+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

extension SKView {
    
    /// Sets the visibility of all debugging-related information and overlays.
    @inlinable
    open func setAllDebugStatsVisibility(to visibility: Bool) {
        self.showsFPS = visibility
        self.showsDrawCount = visibility
        self.showsFields = visibility
        self.showsNodeCount = visibility
        self.showsPhysics = visibility
        self.showsQuadCount = visibility
    }
}

#if os(tvOS) // MARK: - tvOS

extension SKView {

    // This extension forwards focus and press-related events from the view to the scene, to ensure SpriteKit interaction is correctly handled within a SwiftUI view hierarchy.
    // SKView was found to be the appropriate object for these instead of OctopusViewController
    
    // CHECK: Should this be applied for all operating systems to handle game controller input as well?
    
    /// Defers to the `scene` or returns `false` if `scene` is `nil`.
    open override var canBecomeFocused: Bool {
        scene?.canBecomeFocused ?? false
    }

    /// Defers to the `scene` or returns `[parentFocusEnvironment ?? self]` if `scene` is `nil`.
    open override var preferredFocusEnvironments: [UIFocusEnvironment] {
        scene?.preferredFocusEnvironments ?? [self.parentFocusEnvironment ?? self]
    }

    /// Forwards the event to the `scene`.
    open override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        scene?.pressesBegan(presses, with: event)
    }
    
    /// Forwards the event to the `scene`.
    open override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        scene?.pressesEnded(presses, with: event)
    }
    
    /// Forwards the event to the `scene`.
    open override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        self.scene?.pressesChanged(presses, with: event)
    }
    
    /// Forwards the event to the `scene`.
    open override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        self.scene?.pressesCancelled(presses, with: event)
    }
}

#endif
