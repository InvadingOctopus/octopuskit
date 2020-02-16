//
//  OKAgentGoalComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/30.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import SpriteKit
import GameplayKit

/// The base class for components that apply a goal to the behavior of an `OKAgent2D`.
///
/// **Dependencies:** `OKAgent2D`
open class OKAgentGoalComponent: OKComponent {
    
    open override var requiredComponents: [GKComponent.Type]? {
        [OKAgent2D.self]
    }
    
    /// Returns the entity's `OKAgent2D` component, if available.
    public var agent: OKAgent2D? {
        return coComponent(OKAgent2D.self)
    }
    
    public fileprivate(set) var goal: GKGoal?
    
    /// Modifies the goal's influence upon an agent in relation to the agent's other goals.
    public var goalWeight: Float {
        didSet {
            if  let behavior = self.agent?.behavior,
                let goal = self.goal,
                goalWeight != oldValue // Avoid redundancy.
            {
                behavior.setWeight(goalWeight, for: goal)
            }
        }
    }
    
    /// Temporarily sets the goal's weight to `0` to effectively pause the behavior associated with this component, without modifying this component's `goalWeight` property (which is reapplied to the goal when `isPaused` is cleared.)
    public var isPaused: Bool {
        didSet {
            if  isPaused != oldValue, // Avoid redundancy.
                let behavior = self.agent?.behavior,
                let goal = self.goal
            {
                if isPaused {
                    behavior.setWeight(0, for: goal)
                } else {
                    behavior.setWeight(goalWeight, for: goal)
                }
            }
        }
    }
    
    public init(goalWeight: Float = 1.0,
                isPaused: Bool = false)
    {
        self.goalWeight = goalWeight
        self.isPaused = isPaused
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    open override func didAddToEntity() {
        super.didAddToEntity()
        applyGoalToAgent()
    }
    
    /// Removes the current `goal`, if any, from the agent and calls `applyGoalToAgent()` (which calls `createGoal()`) to reapply the goal. Call this when the component's properties have been changed.
    open func recreateAndReapplyGoal() {
        
        // Remove the goal, if any.
        
        removeGoalFromAgent()
        self.goal = nil
        
        // Recreate the goal.

        applyGoalToAgent()
    }
    
    /// Abstract; to be implemented by subclass.
    open func createGoal() -> GKGoal? {
        OctopusKit.logForWarnings.add("Not implemented by subclass")
        return nil
    }
    
    /// Applies this component's goal to the entity's `OKAgent2D` component.
    ///
    /// Creates the goal object if it's currently `nil`, via `createGoal()`.
    open func applyGoalToAgent() {
        
        guard let agent = self.agent else {
            OctopusKit.logForWarnings.add("\(entity) missing OKAgent2D")
            return
        }
        
        // Let the subclass initialize our goal.
        
        if self.goal == nil {
            self.goal = createGoal()
        }
        
        guard let goal = self.goal else {
            OctopusKit.logForWarnings.add("\(self) missing goal")
            return
        }
        
        // If there is no existing behavior on the controlled agent, create one!
        
        if agent.behavior == nil {
            agent.behavior = GKBehavior()
        }
        
        agent.behavior?.setWeight(goalWeight, for: goal)
    }
    
    /// Removes the goal from the entity's `OKAgent2D` component.
    ///
    /// - NOTE: Does not delete this component's `goal` property.
    open func removeGoalFromAgent() {
        guard
            let behavior = self.agent?.behavior,
            let goal = self.goal
            else { return }
        
        behavior.remove(goal)
    }
    
    open override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        
        // Just remove the goal from the agent's behavior; do not reset our properties here, in case this component is reused.
        
        if  let behavior = self.agent?.behavior,
            let goal = self.goal
        {
            behavior.remove(goal)
        }
    }
}

