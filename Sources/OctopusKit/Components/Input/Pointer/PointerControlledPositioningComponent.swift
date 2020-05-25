//
//  PointerControlledPositioningComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/14.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Sets the position of the entity's `NodeComponent` node to the location of the pointer received by the entity's `PointerEventComponent`.
///
/// **Dependencies:** `NodeComponent`, `PointerEventComponent`
public final class PointerControlledPositioningComponent: OKComponent, RequiresUpdatesPerFrame {
    
    // TODO: Add options for buttons and hover.
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self,
         PointerEventComponent.self]
    }
    
    /// If `true`, the `lastEvent` of the entity's `PointerEventComponent` will be used instead of its `latestEventForCurrentFrame`. This flag is set on `didAddToEntity(withNode:)` so that new entities created in response to a pointer event will have their initial position set correctly on the next frame after the first pointer event.
    public var useLastEventInsteadOfLatest: Bool = false
    
    // These `init`s are for Xcode Scene Editor support.
    public override init() { super.init() }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public override func didAddToEntity(withNode node: SKNode) {
        /// CHECK: Should this be on `didAddToEntity()`?
        // Ensure that the set the position is set correctly after this component is added to a [new] entity.
        
        /// ℹ️ BUG FIXED: Without this, a newly-created entity with a `PointerEventComponent` and a `PointerControlledPositioningComponent` would not be moved to the pointer/touch location until the pointer moved or ended, because the new entity would fail the `parent` check on this component's first `update(deltaTime:)`. By the time the entity would be on the scene, the `PointerEventComponent.latestEventForCurrentFrame` may be `nil`.
        /// This flag ensures that a new entity would be placed at the location of the pointer event that it was created in response to (such as a targeting reticule created on a `pointerBegan`).
    
        if  node.scene == nil { /// Should we check `parent` instead of `scene`?
            self.useLastEventInsteadOfLatest = true
        }
    }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        syncEntityPositionWithToPointer()
    }
    
    /// Sets the position of the entity's `NodeComponent` node to the location of the latest pointer event received by the entity's `PointerEventComponent`.
    @inlinable
    public final func syncEntityPositionWithToPointer() {
        guard
            let node    = self.entityNode,
            let parent  = node.parent,
            let pointerEventComponent = coComponent(PointerEventComponent.self),
            
            // See comments above.
            let pointerEvent = useLastEventInsteadOfLatest ? pointerEventComponent.lastEvent : pointerEventComponent.latestEventForCurrentFrame
            else { return }
        
        node.position = pointerEvent.location(in: parent)
        
        #if LOGINPUTEVENTS
        debugLog("pointerEvent: \(pointerEvent), node.position: \(node.position)")
        #endif
        
        /// Update the state of a `NodePointerStateComponent`, if present, for the new position.
        
        if  let nodePointerComponent = coComponent(NodePointerStateComponent.self) {
            nodePointerComponent.updateState(suppressTappedState:    true,
                                             suppressCancelledState: true)
        }
        
        if  useLastEventInsteadOfLatest == true { // CHECK: PERFORMANCE: Does this improve performance? Not setting memory when not needed?
            useLastEventInsteadOfLatest  = false
        }
    }
}
