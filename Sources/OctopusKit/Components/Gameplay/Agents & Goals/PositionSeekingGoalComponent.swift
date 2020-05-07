//
//  PositionSeekingGoalComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/10.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import GameplayKit

/// Sets a `GKGoal` on the entity's `AgentComponent` component to head towards a specified position.
///
/// If you want the agent to only face the target, set the agent's speed properties to `0`.
///
/// Uses an internal `GKAgent2D` to serve as the target of a `GKGoal(toSeekAgent:)` and modifies the target agent's position to match `targetPosition`.
///
/// **Dependencies:** `AgentComponent`
public final class PositionSeekingGoalComponent: AgentGoalComponent {

    /// An internal agent to serve as the target of a `GKGoal(toSeekAgent:)`, whose position will be modified to match `targetPosition`.
    private let targetAgent: GKAgent2D
    
    /// The target position for the `AgentComponent` associated with this component's entity to face and head towards.
    ///
    /// If you want the agent to only face the target, set the agent's speed properties to `0`.
    public var targetPosition: CGPoint? {
        didSet {
            if  targetPosition != oldValue { // Avoid recursion or redundant calls.

                if  let targetPosition = self.targetPosition {
                    targetAgent.position = SIMD2<Float>(targetPosition)
                    
                    // ⚠️ NOTE: If this component is added with an initial `targetPosition == nil` then it is automatically paused. In that case, it must be manually unpaused before it can take effect!
                    if  isPaused && oldValue == nil {
                        OctopusKit.logForDebug("Possible mistake: targetPosition was set but goal isPaused.")
                    }
                    
                    // CHECK: Should `unbrake()` depend on `isPaused` and/or `brakeOnNilTarget`, or always called?
                    
                    if !isPaused { unbrake() }
                
                } else {
                    // If there is no position to track, then pause this goal, otherwise the agent may keep orbiting the last target.
                    isPaused = true
                    // If `brakeOnNilTarget` is set, then decrease the agent's speed towards `0`.
                    if brakeOnNilTarget { brake() }
                }
            }
        }
    }
    
    /// If `true`, the `zRotation` of the entity's `NodeComponent` node is modified to point to the `targetAgent` when this component is added to an entity.
    public var shouldFaceTargetWhenAddedToEntity: Bool
    
    /// A goal to "brake" the agent to a halt when there is no target position.
    public let brakeGoal = GKGoal(toReachTargetSpeed: 0)
    
    /// If `true`, a goal to reach a target speed of `0` will be applied to the agent when `targetPosition` is set to `nil`.
    public var brakeOnNilTarget: Bool = true
    
    /// The weight override for the braking goal. If specified, this value takes precedence over the value of `goalWeight`. If not specified, then the braking weight is set to `goalWeight + 1.0`.
    ///
    /// - Warning: Setting the value too high may "snap" the agent's heading/rotation erratically.
    public var brakeGoalWeightOverride: Float? = nil
    
    /// - Parameter shouldFaceTargetWhenAddedToEntity: If `true`, the `zRotation` of the entity's `NodeComponent` node is modified to point to the `targetAgent` when this component is added to an entity.
    public init(
        targetPosition: CGPoint? = nil,
        shouldFaceTargetWhenAddedToEntity: Bool = false,
        brakeOnNilTarget: Bool = true,
        goalWeight: Float = 10.0,
        brakeGoalWeightOverride: Float? = nil,
        isPaused: Bool = false)
    {
        self.targetAgent = GKAgent2D() // Create an `abstract` agent.
        self.targetPosition = targetPosition
        self.shouldFaceTargetWhenAddedToEntity = shouldFaceTargetWhenAddedToEntity
        self.brakeOnNilTarget = brakeOnNilTarget
        self.brakeGoalWeightOverride = brakeGoalWeightOverride
        
        super.init(goalWeight: goalWeight, isPaused: isPaused)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createGoal() -> GKGoal? {
        if  let targetPosition = self.targetPosition {
            targetAgent.position = SIMD2<Float>(targetPosition)
        }
        return GKGoal(toSeekAgent: targetAgent)
    }
    
    public override func didAddToEntity() {
        super.didAddToEntity()
        
        // If we have no initial position to track, pause this goal, otherwise the agent may start with orbiting around the default of `(0,0)`.
        
        if targetPosition == nil {
            isPaused = true
            // Log a warning in case this component is added with a `nil` position and a developer forgets to unpause.
            OctopusKit.logForDebug("targetPosition is nil — This goal will be paused until manually unpaused.")
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
    
    /// Enables a goal to decrease the agent's speed towards `0`. If `brakeOnNilTarget` is set, this method is called when the `targetPosition` is set to `nil`.
    public func brake() {
        // DESIGN: We should allow braking even if the component `isPaused`. Indeed, the property observer for `targetPosition` calls this method after setting `isPaused`.
        
        guard let behavior = self.agent?.behavior else { return }
        
        // If there is no `brakeGoalWeightOverride`, then set the braking weight to slightly higher than `goalWeight` so that the braking is assured to take precedence over the seeking.
        // CHECK: Is the `+ 1.0` necessary or helpful?
        
        behavior.setWeight(brakeGoalWeightOverride ?? goalWeight + 1.0, for: brakeGoal)
    }
    
    /// Removes the braking goal that was added by `brake()`. This method is called when the `targetPosition` is set to a non-nil value.
    ///
    /// Does nothing if `isPaused`.
    public func unbrake() {
        guard
            !isPaused,
            let behavior = self.agent?.behavior
            else { return }
        
        behavior.remove(brakeGoal)
    }
    
    public override func willRemoveFromEntity() {
        // Remove the extra goal we may have added.
        if let behavior = self.agent?.behavior {
            behavior.remove(brakeGoal)
        }
        
        super.willRemoveFromEntity()
    }
    
}
