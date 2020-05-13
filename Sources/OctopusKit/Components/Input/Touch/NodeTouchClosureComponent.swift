//
//  NodeTouchClosureComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/29.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

#if canImport(UIKit)

/// Executes one of the supplied closures for each state of touch-based player interaction with the entity's `NodeComponent` node.
///
/// This component calls the supplied closures with a reference to `self`, so that the component's user can refer to the instance properties of this component, such as its entity or co-components, at the calling site before it has finished initialization.
///
/// Subclass this component to provide multiple, reusable sets of event handlers for the same entity (as an entity can only have one component of each concrete class.)
///
/// **Example**
///
///     NodeTouchClosureComponent(closures: [
///         .ready              : { ($1 as? SKSpriteNode)?.color = .gray },
///         .touching           : { ($1 as? SKSpriteNode)?.color = .white },
///         .touchingOutside    : { ($1 as? SKSpriteNode)?.color = .orange },
///         .endedOutside       : { ($1 as? SKSpriteNode)?.color = .red },
///         .tapped             : { $1.run(.repeat(.blink(), count: 3)) }
///     ])
///
@available(iOS 13.0, *)
open class NodeTouchClosureComponent: OKComponent, UpdatedPerFrame {

    // ℹ️ This class is not marked as `final` so that subclasses can be created, each providing a different set of event handlers for the same entity.
    
    /// The block of code to be executed for a touch-interaction state by a `NodeTouchClosureComponent`.
    ///
    /// - Parameter component: A reference to `self`; the instance of `NodeTouchClosureComponent` that this closure will be a property of.
    ///
    ///     You can use this to access the instance properties of this component, such as its associated entity and co-components.
    ///
    ///     **Example:** `(component.entity as? OKEntity)?.name`
    ///
    /// - Parameter node: The `NodeComponent` node of the entity associated with this component.
    public typealias NodeTouchClosureType = (
        _ component: NodeTouchClosureComponent,
        _ node: SKNode)
        -> Void
    
    open override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self,
         NodeTouchStateComponent.self]
    }
    
    /// A dictionary that contains blocks of code to execute for each touch interaction state.
    public var closures: [NodeTouchState : NodeTouchClosureType] = [:]
    
    /// If `true`, ignores all touch events and does not execute any of the supplied closures.
    public var isPaused: Bool = false
    
    /// - Parameter closures: A dictionary that contains blocks of code to execute for each touch interaction state.
    ///
    ///     For a description of the closure's signature and parameters, see `NodeTouchClosureComponent.NodeTouchClosureType`.
    public init(closures: [NodeTouchState : NodeTouchClosureType]) {
        self.closures = closures
        super.init()
    }
    
    /// Initializes the closures dictionary with the specified handlers.
    ///
    /// For a description of the closure signature and parameters, see `NodeTouchClosureComponent.NodeTouchClosureType`.
    public init(
        ready:              NodeTouchClosureType? = nil,
        touching:           NodeTouchClosureType? = nil,
        touchingOutside:    NodeTouchClosureType? = nil,
        tapped:             NodeTouchClosureType? = nil,
        cancelled:          NodeTouchClosureType? = nil,
        disabled:           NodeTouchClosureType? = nil)
    {
        self.closures[.ready]           = ready
        self.closures[.touching]        = touching
        self.closures[.touchingOutside] = touchingOutside
        self.closures[.tapped]          = tapped
        self.closures[.endedOutside]    = cancelled
        self.closures[.disabled]        = disabled
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    open override func update(deltaTime seconds: TimeInterval) {
        
        guard
            !isPaused,
            let node = entityNode,
            let nodeTouchComponent = coComponent(NodeTouchStateComponent.self)
            else { return }
     
        // Execute the closure for the current state of the entity's `NodeTouchStateComponent`.
        
        // ⚠️ NOTE: Run the closure ONLY when the `NodeTouchStateComponent`'s state has CHANGED, otherwise the closure would be repeated every frame.
        
        let state = nodeTouchComponent.state // PERFORMANCE: Cache the property access?
        
        if  let closureForCurrentState = self.closures[state],
            nodeTouchComponent.stateChangedThisFrame,
            nodeTouchComponent.previousState != state
        {
            closureForCurrentState(self, node)
        }
        
    }
}

#endif

#if !canImport(UIKit)
@available(macOS, unavailable, message: "Use NodePointerClosureComponent")
public final class NodeTouchClosureComponent: iOSExclusiveComponent {}
#endif
