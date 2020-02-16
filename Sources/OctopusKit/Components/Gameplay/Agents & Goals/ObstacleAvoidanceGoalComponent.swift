//
//  ObstacleAvoidanceGoalComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/08/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Sets a `GKGoal` on the entity's `OKAgent2D` component to avoid the specified obstacles.
///
/// **Dependencies:** `OKAgent2D`
public final class ObstacleAvoidanceGoalComponent: OKAgentGoalComponent {
    
    /// The list of obstacles for the agent of this component's entity to avoid.
    ///
    /// When this value is modified, a new goal is created with the new obstacles. If `obstacles` is set to `nil` then the goal is removed from the agent.
    public var obstacles: [GKObstacle]? {
        didSet {
            if  obstacles != oldValue { // Avoid redundancy.
                obstacles == nil ? removeGoalFromAgent() : recreateAndReapplyGoal()
            }
        }
    }
    
    /// How far in the future (in seconds) a predicted collision must be for the agent to take action to avoid it.
    ///
    /// If a low value is used, an agent speeding toward an obstacle will not swerve or slow until a collision is imminent (and depending on the properties of that agent, it might not be able to move quickly enough to avoid colliding). If a high value is used, the agent will change course leisurely, well before colliding.
    ///
    /// When this value is modified, a new goal is created with the new property.
    public var maxPredictionTime: TimeInterval {
        didSet {
            if  maxPredictionTime != oldValue { // Avoid redundancy.
                recreateAndReapplyGoal()
            }
        }
    }
    
    public init(obstacles: [GKObstacle]? = nil,
                maxPredictionTime: TimeInterval = 1.0,
                goalWeight: Float = 5.0,
                isPaused: Bool = false)
    {
        self.obstacles = obstacles
        self.maxPredictionTime = maxPredictionTime
        super.init(goalWeight: goalWeight, isPaused: isPaused)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createGoal() -> GKGoal? {
        guard let obstacles = self.obstacles else { return nil }
        return GKGoal(toAvoid: obstacles, maxPredictionTime: self.maxPredictionTime)
    }
}

