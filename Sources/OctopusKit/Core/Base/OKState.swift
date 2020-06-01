//
//  OKState.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/06/01.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Represents a state in a state machine.
///
/// Adds convenience features to `GKState`. The base class for `OKGameState` and `OKEntityState`.
open class OKState: GKState {
    
    /// Specifies the possible states that this state may transition to. If this array is empty, then all states are allowed (the default.)
    ///
    /// Checked by `isValidNextState(_:)`.
    ///
    /// - Important: This property should describe the **static** relationships between state classes that determine the set of edges in a state machine’s state graph; Do **not** perform conditional logic in this property to conditionally control state transitions. Check conditions before attempting to transition to a different state.
    @inlinable
    open var validNextStates: [OKState.Type] {
        []
    }
    
    /// Returns `true` if the `validNextStates` property contains `stateClass` or is an empty array (which means all states are allowed.)
    ///
    /// - Important: Do not override this method to conditionally control state transitions. Instead, perform such conditional logic before transitioning to a different state.
    open override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // https://developer.apple.com/documentation/gameplaykit/gkstate/1501221-isvalidnextstate
        // Your implementation of this method should describe the static relationships between state classes that determine the set of edges in a state machine’s state graph.
        /// ⚠️ Do **not** use this method to conditionally control state transitions—instead, perform such conditional logic before calling a state machine’s `enter(_:)` method.
        // By restricting the set of valid state transitions, you can use a state machine to enforce invariant conditions in your code. For example, if one state class can be entered only after a state machine has passed through a series of other states, code in that state class can safely assume that any actions performed by those other states have already occurred.
        
        validNextStates.isEmpty || validNextStates.contains { stateClass == $0 }
    }
}
