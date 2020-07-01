//
//  OKStateMachine.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/07/01.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// A finite-state machine.
///
/// Adds convenience features to `GKStateMachine`, such as remembering the previous state.
open class OKStateMachine: GKStateMachine {

    /// The previous state, if any. Set upon a successful state transition when `enter(_:)` is called.
    public private(set) weak var previousState: GKState? // CHECK: Should this be `weak`?

    @inlinable
    public var previousStateClass: GKState.Type? {
        if  let previousState = self.previousState {
            return type(of: previousState)
        } else {
            return nil
        }
    }

    /// Attempts to transition the state machine from its current state to a state of the specified class, and sets the `previousState` property if the transition was successful.
    open override func enter(_ stateClass: AnyClass) -> Bool {
        let previousState   = self.currentState
        let didEnter        = super.enter(stateClass)

        if  didEnter,
            previousState != self.currentState {
            self.previousState = previousState
        }

        return didEnter
    }
}
