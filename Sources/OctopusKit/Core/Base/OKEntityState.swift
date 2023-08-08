//
//  OKEntityState.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/13.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import OctopusCore
import GameplayKit

public typealias OctopusEntityState = OKEntityState

/// A logical state which may be associated with an entity's `StateMachineComponent`. Dictates the validity of state transitions and applies modifications to the entity, such as adding or removing components, upon entering from or exiting to specific states.
open class OKEntityState: OKState {
    
    // NOTE: The component lists are `Array`s instead of `Set`s so the order can be preserved.
    
    public unowned let entity: OKEntity // CHECK: Should this be `unowned`?
    
    /// ❕ NOTE: Component arrays should be of type `GKComponent` instead of the more specific `OKComponent`, so that `GKAgent` and `AgentComponent` etc. can be added.
    
    /// The components to be added to the entity when its state machine enters this state.
    ///
    /// 💡 Call `syncComponentArrays()` to match `componentTypesToRemoveOnExit` to the types of components in this array. For more granular control, e.g. using different components depending on the *previous* state, override `didEnter(from:)`.
    ///
    /// - Note: Adding a component will replace any other component of that class, if the entity already has any.
    ///
    /// - IMPORTANT: ❕ This property is ineffective if the `OKEntityState` subclass overrides `didEnter(from:)` without calling `super.didEnter(from:)`.
    public var componentsToAddOnEntry: [GKComponent]?
    
    /// The component classes to be removed from the entity when its state machine exits this state.
    ///
    /// 💡 Call `syncComponentArrays()` to match this array to the types of components in `componentsToAddOnEntry`. For more granular control, e.g. removing different components depending on the *upcoming* state, override `willExit(to:)`.
    ///
    /// - IMPORTANT: ❕ This property is ineffective if the `OKEntityState` subclass overrides `willExit(to:)` without calling `super.willExit(to:)`.
    public var componentTypesToRemoveOnExit: [GKComponent.Type]?
    
    // MARK: - Life Cycle
    
    public init(entity: OKEntity) {
        self.entity = entity
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    /// - IMPORTANT: The subclass **must** call `super.didEnter(from: previousState)` to add `componentsToAddOnEntry`.
    open override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        OKLog.states.debug("\(📜("\"\(entity.name)\" \(previousState) → \(self)"))")
        
        if  let componentsToAddOnEntry = self.componentsToAddOnEntry {
            // CHECK: Count before and after?
            entity.addComponents(componentsToAddOnEntry)
        }
    }
    
    /// - IMPORTANT: The subclass **must** call `super.willExit(to: nextState)` to remove `componentTypesToRemoveOnExit`.
    open override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        OKLog.states.debug("\(📜("\"\(entity.name)\" \(self) → \(nextState)"))")
        
        if  let componentTypesToRemoveOnExit = self.componentTypesToRemoveOnExit {
            // CHECK: Count before and after?
            for componentType in componentTypesToRemoveOnExit {
                entity.removeComponent(ofType: componentType)
            }
        }
    }
    
    // MARK: - Common Tasks
    
    /// Sets `componentsToAddOnEntry` to the specified array, then sets `componentTypesToRemoveOnExit` to match their types.
    @inlinable
    open func setComponents(_ components: [GKComponent]?) { // `nil` must be explicit.
        self.componentsToAddOnEntry = components
        syncComponentArrays()
    }
    
    /// Sets `componentTypesToRemoveOnExit` to the types of all the components in `componentsToAddOnEntry`.
    ///
    /// If `componentsToAddOnEntry` is `nil` then `componentTypesToRemoveOnExit` is set to `nil` as well.
    @inlinable
    open func syncComponentArrays() {
        componentTypesToRemoveOnExit = componentsToAddOnEntry?.map { type(of: $0) } ?? nil
    }
    
}
