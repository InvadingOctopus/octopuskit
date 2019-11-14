//
//  TouchControlledPositioningComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/19.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

#if canImport(UIKit)

/// Sets the position of the entity's `SpriteKitComponent` node to the location of the first or latest touch received by the entity's `TouchEventComponent`.
///
/// **Dependencies:** `SpriteKitComponent`, `TouchEventComponent`
@available(iOS 13.0, *)
public final class TouchControlledPositioningComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [SpriteKitComponent.self,
         TouchEventComponent.self]
    }
    
    public var trackLatestTouchInsteadOfFirst: Bool = false

    public var trackedTouch: UITouch? {
        return (trackLatestTouchInsteadOfFirst ? coComponent(ofType: TouchEventComponent.self)?.latestTouch :  coComponent(ofType: TouchEventComponent.self)?.firstTouch)
    }
    
    public init(trackLatestTouchInsteadOfFirst: Bool = false) {
        self.trackLatestTouchInsteadOfFirst = trackLatestTouchInsteadOfFirst
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        guard
            let node = self.entityNode,
            let parent = node.parent,
            let trackedTouch = self.trackedTouch
            else { return }
        
        node.position = trackedTouch.location(in: parent)
        
        // Update the state of a `NodeTouchStateComponent`, if present, for the new position.
        
        if let nodeTouchComponent = coComponent(NodeTouchStateComponent.self) {
            nodeTouchComponent.updateState(suppressTappedState: true,
                                           suppressCancelledState: true)
        }
        
    }
}

#endif

#if !canImport(UIKit)
@available(macOS, unavailable, message: "Use PointerControlledPositioningComponent")
public final class TouchControlledPositioningComponent: iOSExclusiveComponent {}
#endif
