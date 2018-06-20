//
//  PositionSeekingGoalComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/10.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Add stopping behavior?

import GameplayKit

/// Sets a `GKGoal` on the entity's `OctopusAgent2D` component to head towards a specified position.
///
/// If you want the agent to only face the target, set the agent's speed properties to `0`.
///
/// Uses an internal `GKAgent2D` to serve as the target of a `GKGoal(toSeekAgent:)` and modifies the target agent's position to match `targetPosition`.
///
/// **Dependencies:** `OctopusAgent2D`
public final class PositionSeekingGoalComponent: OctopusAgentGoalComponent {

    /// An internal agent to serve as the target of a `GKGoal(toSeekAgent:)`, whose position will be modified to match `targetPosition`.
    private let targetAgent: GKAgent2D
    
    /// The target position for the `OctopusAgent2D` associated with this component's entity to face and head towards.
    ///
    /// If you want the agent to only face the target, set the agent's speed properties to `0`.
    public var targetPosition: CGPoint? {
        didSet {
            
            if targetPosition != oldValue { // Avoid recursion or redundant calls.

                if let targetPosition = self.targetPosition {
                    targetAgent.position = float2(targetPosition)
                }
                else {
                    // If there is no position to track, then pause this goal.
                    self.isPaused = true
                }
            }
            
        }
    }
    
    /// If `true`, the `zRotation` of the entity's `SpriteKitComponent` node is modified to point to the `targetAgent` when this component is added to an entity.
    public var shouldFaceTargetWhenAddedToEntity: Bool
    
    /// - Parameter shouldFaceTargetWhenAddedToEntity: If `true`, the `zRotation` of the entity's `SpriteKitComponent` node is modified to point to the `targetAgent` when this component is added to an entity.
    public init(
        targetPosition: CGPoint? = nil,
        shouldFaceTargetWhenAddedToEntity: Bool = false,
        goalWeight: Float = 10.0,
        isPaused: Bool = false)
    {
        self.targetAgent = GKAgent2D() // Create an `abstract` agent.
        self.shouldFaceTargetWhenAddedToEntity = shouldFaceTargetWhenAddedToEntity
        self.targetPosition = targetPosition
        super.init(goalWeight: goalWeight, isPaused: isPaused)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createGoal() -> GKGoal? {
        if let targetPosition = self.targetPosition {
            targetAgent.position = float2(targetPosition)
        }
        return GKGoal(toSeekAgent: targetAgent)
    }
    
    public override func didAddToEntity() {
        super.didAddToEntity()
        
        // If we have no initial position to track, pause this goal.
        
        if self.targetPosition == nil {
            self.isPaused = true
        }
    }
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        if  shouldFaceTargetWhenAddedToEntity,
            let targetPosition = self.targetPosition
        {
            node.zRotation = node.position.radians(to: targetPosition)
        }
    }
}
