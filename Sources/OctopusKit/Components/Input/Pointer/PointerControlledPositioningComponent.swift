//
//  PointerControlledPositioningComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/14.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Sets the position of the entity's `SpriteKitComponent` node to the location of the pointer received by the entity's `PointerEventComponent`.
///
/// **Dependencies:** `SpriteKitComponent`, `PointerEventComponent`
public final class PointerControlledPositioningComponent: OKComponent, OKUpdatableComponent {
    
    // TODO: Add options for buttons and hover.
    
    public override var requiredComponents: [GKComponent.Type]? {
        [SpriteKitComponent.self,
         PointerEventComponent.self]
    }
    
    // These `init`s are for Xcode Scene Editor support.
    public override init() { super.init() }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        guard
            let node    = self.entityNode,
            let parent  = node.parent,
            let pointerEventComponent = coComponent(PointerEventComponent.self),
            let latestEvent = pointerEventComponent.latestEventForCurrentFrame
            else { return }
        
        node.position = latestEvent.location(in: parent)
        
        // Update the state of a `NodePointerStateComponent`, if present, for the new position.
        
        if  let nodePointerComponent = coComponent(NodePointerStateComponent.self) {
            nodePointerComponent.updateState(suppressTappedState:    true,
                                             suppressCancelledState: true)
        }
        
    }
}
