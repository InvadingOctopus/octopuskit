//
//  RelayComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// A component that points to another component in a different entity. Used for sharing a single component instance across different entities.
///
/// Useful for cases like dynamically linking input event manager components (e.g. `TouchEventComponent`) from a scene to input-controlled components (e.g. `TouchControlledPositioningComponent`) in an entity.
///
/// The `GKComponent.coComponent(ofType:)` and `GKEntity.componentOrRelay(ofType:)` methods will check the entity for a `RelayComponent` which points to a component of the specified type, if the entity itself does not have a component of the specified type.
///
/// - Important: `GKEntity.component(ofType:)` does *not* automatically substitute a `RelayComponent` for the specified component class, due to GameplayKit/Swift limitations. Use `GKEntity.componentOrRelay(ofType:)` or `GKComponent.coComponent(ofType:)` to automatically look for `RelayComponent`s.
public final class RelayComponent<MasterComponentType: GKComponent>: OctopusComponent {
    
    // ℹ️ GameplayKit does not allow an entity to have more than one component of the same class, but a generic class with different associated types can be added, e.g. `RelayComponent<Component1>` and `RelayComponent<Component2>`.
    
    /// The component that this `RelayComponent` holds a reference to.
    ///
    /// At runtime, this property resolves to either the `directlyReferencedComponent`, or if that is `nil`, the `sceneComponentType`, which checks the scene entity of the `SpriteKitComponent` node of this `RelayComponent`'s entity.
    ///
    /// The `GKComponent.coComponent(ofType:)` and `GKEntity.componentOrRelay(ofType:)` methods will check the entity for a `RelayComponent` which points to a component matching the specified type, if the entity itself does not have a component of the specified type.
    ///
    /// - Important: `GKEntity.component(ofType:)` does *not* automatically substitute a `RelayComponent` for the specified component class, due to GameplayKit/Swift limitations. Use `GKEntity.componentOrRelay(ofType:)` or `GKComponent.coComponent(ofType:)` to automatically look for `RelayComponent`s.
    public var target: MasterComponentType? {
        if let directlyReferencedComponent = self.directlyReferencedComponent {
            return directlyReferencedComponent
        }
        else if let sceneComponentType = self.sceneComponentType,
                let sceneComponent = self.entityNode?.scene?.entity?.component(ofType: sceneComponentType)
        {
            return sceneComponent
        }
        else {
            return nil
        }
    }
    
    /// A direct reference to a shared component. If this value is `nil`, then this `RelayComponent` will point to the `sceneComponentType`, if specified.
    public var directlyReferencedComponent: MasterComponentType?
    
    // PERFORMANCE: The increased property accesses may decrease performance, especially for components like `TouchEventComponent` that are accessed every frame.
    
    /// The type of component to look for in the scene entity of the `SpriteKitComponent` node of this `RelayComponent`'s entity.
    ///
    /// This property is only used if the `directlyReferencedComponent` is `nil.
    public var sceneComponentType: MasterComponentType.Type?
    
    public init(for targetComponent: MasterComponentType?) {
        // ℹ️ DESIGN: `target` is optional so that we can write stuff like `entity1.addComponent(RelayComponent(for: entity2.component(ofType: SomeComponent.self)))`
        self.directlyReferencedComponent = targetComponent
        super.init()
    }
    
    /// Creates a `RelayComponent` which points to a component of the specified type in the scene entity associated with the `SpriteKitComponent` node of the `RelayComponent`'s entity.
    public init (sceneComponentType: MasterComponentType.Type) {
        self.sceneComponentType = sceneComponentType
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
   
    public override func didAddToEntity() {
        super.didAddToEntity()
        
        guard let entity = self.entity else { return }
        
        // Warn if the entity already has the actual component that we're a relay for.
        
        if  let existingComponent = coComponent(MasterComponentType.self, ignoreRelayComponents: true)
        {
            if existingComponent === target {
                OctopusKit.logForWarnings.add("\(entity) already has \(existingComponent)")
            }
            else {
                OctopusKit.logForWarnings.add("\(entity) already has a \(type(of: existingComponent)) component: \(existingComponent)")
            }
        }
        
    }
}

