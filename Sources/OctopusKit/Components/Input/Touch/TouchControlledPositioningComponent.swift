//
//  TouchControlledPositioningComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/19.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Sets the position of the entity's `SpriteKitComponent` node to the location of the first touch received by the entity's `TouchEventComponent`.
///
/// **Dependencies:** `SpriteKitComponent`, `TouchEventComponent`
public final class TouchControlledPositioningComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        return [SpriteKitComponent.self,
                TouchEventComponent.self]
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        guard
            let node = self.entityNode,
            let parent = node.parent,
            let firstTrackedTouch = coComponent(TouchEventComponent.self)?.firstTouch
            else { return }
        
        node.position = firstTrackedTouch.location(in: parent)
        
        // Update the `TouchStateComponent` for the new position if there is one.
        
        if let nodeTouchComponent = coComponent(NodeTouchComponent.self) {
            nodeTouchComponent.updateState(suppressTappedState: true,
                                            suppressCancelledState: true)
        }
        
    }
}

