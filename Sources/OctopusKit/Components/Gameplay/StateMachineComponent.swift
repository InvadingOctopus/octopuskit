//
//  StateMachineComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/12.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Encapsulates a `GKStateMachine` and updates its current state on every frame.
public final class StateMachineComponent <StateMachineClass>: OKComponent, RequiresUpdatesPerFrame
    where StateMachineClass: GKStateMachine
{

    public let stateMachine: StateMachineClass
    
    /// The class of the state to enter after `didAddToEntity()` is called. Repeated whenever this component is added to a new entity.
    public var stateOnAddingToEntity:       GKState.Type?
    
    /// The class of the state to enter after `update(deltaTime:)` is first called, *before* `stateMachine.update(deltaTime:)` is called. This property is ignored on subsequent updates, until this component is added to a new entity.
    public var stateOnFirstUpdate:          GKState.Type?
    
    /// The class of the state to enter after `willRemoveFromEntity()` is called. Repeated whenever this component is removed from an entity.
    public var stateOnRemovingFromEntity:   GKState.Type?
    
    /// If `true` then `stateOnFirstUpdate` is ignored. Set to `false` after `willRemoveFromEntity()` is called.
    public fileprivate(set) var didSetStateOnFirstUpdate = false
    
    // MARK: - Initialization
    
    /// Creates a `StateMachineComponent` and signals the `stateMachine` to enter `initialState`.
    ///
    /// To automatically set the state later in this component's life-cycle, specify one or more of the `stateOn...` parameters.
    /// - Parameters:
    ///   - stateMachine: An instance of the state machine that will be controlled by this component.
    ///   - initialState: The class (*not* an instance) of the state to enter when this component is initialized, i.e. immediately after this init.
    ///   - stateOnAddingToEntity:  The class (*not* an instance) of the state to enter *each time* this component is added to an entity.
    ///   - stateOnFirstUpdate:     The class (*not* an instance) of the state to enter *once* this component performs its first frame update. This property is ignored on subsequent updates, until this component is added to a new entity.
    ///   - stateOnRemovingFromEntity:  The class (*not* an instance) of the state to enter *each time* this component is removed from an entity.
    public init(
        stateMachine:               StateMachineClass,
        initialState:               GKState.Type? = nil,
        stateOnAddingToEntity:      GKState.Type? = nil,
        stateOnFirstUpdate:         GKState.Type? = nil,
        stateOnRemovingFromEntity:  GKState.Type? = nil)
    {
        self.stateMachine               = stateMachine
        self.stateOnAddingToEntity      = stateOnAddingToEntity
        self.stateOnFirstUpdate         = stateOnFirstUpdate
        self.stateOnRemovingFromEntity  = stateOnRemovingFromEntity
        super.init()
        
        if  let initialState = initialState {
            stateMachine.enter(initialState)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Life Cycle
    
    @inlinable
    public override func didAddToEntity() {
        super.didAddToEntity()
        if  let stateOnAddingToEntity = self.stateOnAddingToEntity {
            stateMachine.enter(stateOnAddingToEntity)
        }
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        if  !didSetStateOnFirstUpdate,
            let stateOnFirstUpdate = self.stateOnFirstUpdate
        {
            stateMachine.enter(stateOnFirstUpdate)
            didSetStateOnFirstUpdate = true
        }
        
        stateMachine.update(deltaTime: seconds)
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        
        if  let stateOnRemovingFromEntity = self.stateOnRemovingFromEntity {
            stateMachine.enter(stateOnRemovingFromEntity)
        }
        
        didSetStateOnFirstUpdate = false
    }
}
