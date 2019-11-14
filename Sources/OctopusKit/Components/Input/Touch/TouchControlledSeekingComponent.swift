//
//  TouchControlledSeekingComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/12/06.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: A way to not rely on a `SpriteKitComponent` so that entities without a visual representation (i.e. only agents or "ghosts") may be able to use this component. However, that requires the `TouchEventComponent` to associate each tracked touch with the node that received it.

import GameplayKit

#if os(iOS)
    
/// Directs the `PositionSeekingGoalComponent` of the entity towards the point touched by the player.
///
/// **Dependencies:** `PositionSeekingGoalComponent, SpriteKitComponent, TouchEventComponent`
public final class TouchControlledSeekingComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [PositionSeekingGoalComponent.self,
         SpriteKitComponent.self,
         TouchEventComponent.self]
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        guard
            let parent = self.entityNode?.parent,
            let positionSeekingComponent = coComponent(PositionSeekingGoalComponent.self),
            let touchEventComponent = coComponent(TouchEventComponent.self)
            else { return }
        
        // TODO: A less "hacky" way of querying the first touch and its state. The `phase` property does not help :(
        
        // Set the goal to seek the location of the first touch that's being tracked.
        
        // ⚠️ Do not change the `positionSeekingComponent.isPaused` flag here; just control the `PositionSeekingComponent` via its `targetPosition`, and let other components pause or unpause the `PositionSeekingComponent`. e.g. a `NodeTouchClosureComponent` may want to allow seeking only if the node is being touched (and dragged.)
        
        if let firstTouch = touchEventComponent.firstTouch {
            
            // CHECK: Should we unpause the `PositionSeekingComponent` when the `firstTouch` begins (so we don't set the property on every frame)?
            // if touchEventComponent.touchesBegan?.touches.contains(firstTouch) ?? false {
                // positionSeekingComponent.isPaused = false
            // }
            
            let targetPosition = firstTouch.location(in: parent) // TODO: Verify with nested nodes etc.
            
            #if LOGINPUTEVENTS
            debugLog("\(positionSeekingComponent.targetPosition)")
            #endif
            
            positionSeekingComponent.isPaused = false // Unpause the component in case it was initially added with a `nil` position, which automatically pauses the goal otherwise it may orbit around `(0,0)`.
            positionSeekingComponent.targetPosition = targetPosition
        }
        // If there is no `firstTouch` and there has been a `touchesEnded` or `touchesCancelled` event during this frame, then that means the `firstTouch` has just ended.
        else if touchEventComponent.touchesEnded != nil || touchEventComponent.touchesCancelled != nil {
            // Remove the target position.
            positionSeekingComponent.targetPosition = nil
            positionSeekingComponent.isPaused = true // Pause the component, otherwise the agent may orbit around the last `targetPosition`.
        }
        
    }

}

#endif

#if !canImport(UIKit)
public final class TouchControlledSeekingComponent: iOSExclusiveComponent {}
#endif
