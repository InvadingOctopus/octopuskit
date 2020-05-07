//
//  PointerControlledSeekingComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/4.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Directs the `PositionSeekingGoalComponent` of the entity towards the point touched or clicked by the player.
///
/// **Dependencies:** `PositionSeekingGoalComponent, NodeComponent, PointerEventComponent`
public final class PointerControlledSeekingComponent: OKComponent, OKUpdatableComponent {

    // TODO: A way to not rely on a `NodeComponent` so that entities without a visual representation (i.e. only agents or "ghosts") may be able to use this component.
    
    public override var requiredComponents: [GKComponent.Type]? {
        [PositionSeekingGoalComponent.self,
         NodeComponent.self,
         PointerEventComponent.self]
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        guard
            let parent = self.entityNode?.parent,
            let positionSeekingComponent = coComponent(PositionSeekingGoalComponent.self),
            let pointerEventComponent = coComponent(PointerEventComponent.self)
            else { return }
        
        // Set the goal to seek the location of the pointer.
        
        // ⚠️ Do not change the `positionSeekingComponent.isPaused` flag here; just control the `PositionSeekingComponent` via its `targetPosition`, and let other components pause or unpause the `PositionSeekingComponent`. e.g. a `NodeTouchClosureComponent` may want to allow seeking only if the node is being touched/clicked (and dragged.)
        
        if let latestEvent = pointerEventComponent.latestEventForCurrentFrame {
            
            // CHECK: Should we unpause the `PositionSeekingComponent` on the `pointerBegan` event (so we don't set the property on every frame)?
            // if  pointerEventComponent.pointerBegan != nil {
                // positionSeekingComponent.isPaused = false
            // }
            
            let targetPosition = latestEvent.location(in: parent) // TODO: Verify with nested nodes etc.
            
            #if LOGINPUTEVENTS
            debugLog("\(positionSeekingComponent.targetPosition)")
            #endif
            
            positionSeekingComponent.isPaused = false // Unpause the component in case it was initially added with a `nil` position, which automatically pauses the goal otherwise it may orbit around `(0,0)`.
            positionSeekingComponent.targetPosition = targetPosition
        }
        
        // If there was a `pointerEnded` event, pause the component, otherwise the agent may orbit around the last `targetPosition`.
        // Do not use `else if` because the check for `latestEventForCurrentFrame` above will always be true.
        
        if  pointerEventComponent.pointerEnded != nil {
            // Remove the target position.
            positionSeekingComponent.targetPosition = nil
            positionSeekingComponent.isPaused = true
        }
        
    }

}
