//
//  AgentSeekingGoalComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/29.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Add stopping behavior?

import GameplayKit

/// Sets a `GKGoal` on the entity's `OKAgent2D` component to seek out another agent.
///
/// **Dependencies:** `OKAgent2D`
public final class AgentSeekingGoalComponent: OKAgentGoalComponent {
    
    /// The target for the agent of this component's entity to seek.
    ///
    /// When this value is modified, a new goal is created with the new target. If `targetAgent` is set to `nil` then the goal is removed from the agent.
    public var targetAgent: OKAgent2D? {
        didSet {
            if  targetAgent != oldValue { // Avoid redundancy.
                targetAgent == nil ? removeGoalFromAgent() : recreateAndReapplyGoal()
            }
        }
    }

    /// If `true`, the `zRotation` of the entity's `NodeComponent` node is modified to point to the `targetAgent` when this component is added to an entity.
    public var shouldFaceTargetWhenAddedToEntity: Bool
    
    /// - Parameter shouldFaceTargetWhenAddedToEntity: If `true`, the `zRotation` of the entity's `NodeComponent` node is modified to point to the `targetAgent` when this component is added to an entity.
    public init(targetAgent: OKAgent2D? = nil,
                shouldFaceTargetWhenAddedToEntity: Bool = false,
                goalWeight:  Float = 5.0,
                isPaused:    Bool  = false)
    {
        self.targetAgent = targetAgent
        self.shouldFaceTargetWhenAddedToEntity = shouldFaceTargetWhenAddedToEntity
        super.init(goalWeight: goalWeight, isPaused: isPaused)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createGoal() -> GKGoal? {
        guard let targetAgent = self.targetAgent else { return nil }
        return GKGoal(toSeekAgent: targetAgent)
    }
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        if  shouldFaceTargetWhenAddedToEntity,
            let targetPosition = self.targetAgent?.position
        {
            node.zRotation = node.position.radians(to: CGPoint(targetPosition))
        }
    }
}
