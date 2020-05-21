//
//  StateMachineComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/12.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Encapsulates a `GKStateMachine` and updates its current `GKState` on every frame.
public final class StateMachineComponent<StateMachineClass: GKStateMachine>: OKComponent, RequiresUpdatesPerFrame {

    public let stateMachine: StateMachineClass
    
    /// The class of the state to enter when `didAddToEntity()` is called.
    public var stateClassWhenAddingToEntity: GKState.Type?
    
    /// The class of the state to enter when `update(deltaTime:)` is first called.
    ///
    /// This property is ignored on subsequent updates.
    public var stateClassWhenFirstUpdating: GKState.Type?
    
    public fileprivate(set) var didSetStateOnFirstUpdate = false
    
    /// The class of the state to enter when `willRemoveFromEntity()` is called.
    public var stateClassWhenRemovingFromEntity: GKState.Type?
    
    /// Creates a `StateMachineComponent` and signals the `stateMachine` to enter `initialState`.
    ///
    /// To automatically set the state later in the component's life-cycle, specify one or more of the `stateWhen...` parameters.
    public init(
        stateMachine: StateMachineClass,
        initialStateClass: GKState.Type? = nil,
        stateClassWhenAddingToEntity: GKState.Type? = nil,
        stateClassWhenFirstUpdating: GKState.Type? = nil,
        stateClassWhenRemovingFromEntity: GKState.Type? = nil)
    {
        self.stateMachine = stateMachine
        self.stateClassWhenAddingToEntity = stateClassWhenAddingToEntity
        self.stateClassWhenFirstUpdating = stateClassWhenFirstUpdating
        self.stateClassWhenRemovingFromEntity = stateClassWhenRemovingFromEntity
        super.init()
        
        if let initialState = initialStateClass {
            stateMachine.enter(initialState)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func didAddToEntity() {
        super.didAddToEntity()
        if let stateClassWhenAddingToEntity = self.stateClassWhenAddingToEntity {
            stateMachine.enter(stateClassWhenAddingToEntity)
        }
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        if  !didSetStateOnFirstUpdate,
            let stateClassWhenFirstUpdating = self.stateClassWhenFirstUpdating
        {
            stateMachine.enter(stateClassWhenFirstUpdating)
            didSetStateOnFirstUpdate = true
        }
        
        stateMachine.update(deltaTime: seconds)
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        if let stateClassWhenRemovingFromEntity = self.stateClassWhenRemovingFromEntity {
            stateMachine.enter(stateClassWhenRemovingFromEntity)
        }
    }
}
