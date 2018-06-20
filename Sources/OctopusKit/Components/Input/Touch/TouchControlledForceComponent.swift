//
//  TouchControlledForceComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/16.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Enforce `isUserInteractionEnabled`?

// CHECKED: This component works whether the `TouchEventComponent` is added to a sprite entity or the scene entity. :)

// CHECKED: DESIGN: The implementation of `trackedTouch` (probably because of the `break` statement) allows "new" touches to "grab" the entity; i.e. moving with Finger 1, then touching with Finger 2, allows Finger 2 to grab the entity. This is the naturally expected behavior! :)

// TODO: Fix physics and grabbing behavior etc.

import SpriteKit
import GameplayKit

#if os(iOS)

///
/// **Dependencies:** `PhysicsComponent`, `SpriteKitComponent`, `TouchEventComponent`
public final class TouchControlledForceComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        return [SpriteKitComponent.self,
                PhysicsComponent.self,
                TouchEventComponent.self]
    }
    
    public var boost: CGFloat
    
    public fileprivate(set) var trackedTouch: UITouch? // TODO: Add multitouch tracking?
    
    public init(boost: CGFloat = 10) {
        self.boost = boost
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard let touchEventComponent = coComponent(TouchEventComponent.self),
            let node = entityNode,
            let parent = node.scene,
            let physicsBody = node.physicsBody
            else { return }
        
        // Did player touch us?
        
        if let touchEvent = touchEventComponent.touchesBegan {
            
            for touch in touchEvent.touches {
                
                if node.contains(touch.location(in: parent)) { // TODO: Verify
                    self.trackedTouch = touch
                    break
                }
            }
        }
        
        // Move the node if the touch we're tracking has moved.
        
        if
            let touchEvent = touchEventComponent.touchesMoved,
            let trackedTouch = self.trackedTouch,
            touchEvent.touches.contains(trackedTouch)
        {
            let currentTouchLocation = trackedTouch.location(in: parent)
            let previousTouchLocation = trackedTouch.previousLocation(in: parent)
            let vector = CGVector(dx: (currentTouchLocation.x - previousTouchLocation.x) * boost,
                                  dy: (currentTouchLocation.y - previousTouchLocation.y) * boost)
            physicsBody.applyForce(vector)
        }
        
        // Stop tracking a touch if the player cancelled it.
        
        if
            let touchEvent = touchEventComponent.touchesEnded ?? touchEventComponent.touchesCancelled,
            let trackedTouch = self.trackedTouch,
            touchEvent.touches.contains(trackedTouch)
        {
            self.trackedTouch = nil
        }
    }
}

#else
    
public final class TouchControlledForceComponent: iOSExclusiveComponent {}
    
#endif
