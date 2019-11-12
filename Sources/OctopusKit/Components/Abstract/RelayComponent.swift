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
public final class RelayComponent <MasterComponentType> : OctopusComponent
    where MasterComponentType: GKComponent
{
    
    // ℹ️ GameplayKit does not allow an entity to have more than one component of the same class, but a generic class with different associated types can be added, e.g. `RelayComponent<Component1>` and `RelayComponent<Component2>`.
    
    /// The component that this `RelayComponent` holds a reference to.
    ///
    /// At runtime, this property resolves to either the `directlyReferencedComponent`, or if that is `nil`, the `sceneComponentType`, which checks the scene entity of the `SpriteKitComponent` node of this `RelayComponent`'s entity.
    ///
    /// The `GKComponent.coComponent(ofType:)` and `GKEntity.componentOrRelay(ofType:)` methods will check the entity for a `RelayComponent` which points to a component matching the specified type, if the entity itself does not have a component of the specified type.
    ///
    /// - IMPORTANT: `GKEntity.component(ofType:)` does *not* automatically substitute a `RelayComponent` for the specified component class, due to GameplayKit/Swift limitations. Use `GKEntity.componentOrRelay(ofType:)` or `GKComponent.coComponent(ofType:)` to automatically look for `RelayComponent`s.
    @inlinable
    public var target: MasterComponentType? {
        
        #if LOGECSVERBOSE
        debugLog("self: \(self)")
        #endif
        
        if  let directlyReferencedComponent = self.directlyReferencedComponent {
            
            #if LOGECSVERBOSE
            debugLog("directlyReferencedComponent: \(directlyReferencedComponent)")
            #endif
            
            return directlyReferencedComponent
        
        }   else if let sceneComponentType = self.sceneComponentType {
            
            #if LOGECSVERBOSE
            debugLog("Accessing self.entityNode?.scene?.entity?.component(ofType: \(sceneComponentType))")
            #endif
            
            // ❕ NOTE: Accessing `entityNode` used to cause infinite recursion because `GKEntity.node` calls `GKEntity.componentOrRelay(ofType:)` which leads back here. :)
            // FIXED: `GKEntity.node` now uses `GKEntity.component(ofType:)` instead of `GKEntity.componentOrRelay(ofType:)` and checks for `directlyReferencedComponent` instead of this `target` property.
            
            return self.entityNode?.scene?.entity?.component(ofType: sceneComponentType)
            
        }   else {
            return nil
        }
    }
    
    /// A direct reference to a shared component. If this value is `nil`, then this `RelayComponent` will point to the `sceneComponentType`, if specified.
    public var directlyReferencedComponent: MasterComponentType?
    
    // PERFORMANCE: The increased property accesses may decrease performance, especially for components like `TouchEventComponent` that are accessed every frame.
    
    /// The type of component to look for in the entity which represents the scene associated with the `SpriteKitComponent` node of this `RelayComponent`'s entity.
    ///
    /// `RelayComponent.entityNode?.scene?.entity?.component(ofType: sceneComponentType)`
    ///
    /// This property is only used if the `directlyReferencedComponent` is `nil.
    public var sceneComponentType: MasterComponentType.Type?
    
    /// This helps `GKEntity.componentOrRelay(ofType:)` see the correct concrete type at runtime, e.g. when comparing with `OctopusComponent.requiredComponents`.
    public override var componentType: GKComponent.Type {
        
        #if LOGECSVERBOSE
        debugLog("self: \(self), \(type(of: self)), target?.componentType: \(target?.componentType)")
        #endif
        
        return target?.componentType ?? type(of: self)
    }
    
    public override var description: String {
        "\(super.description), directlyReferencedComponent: \(directlyReferencedComponent), sceneComponentType: \(sceneComponentType)"
    }
    
    // MARK: - Life Cycle
    
    public init(for targetComponent: MasterComponentType?) {
        // ℹ️ DESIGN: `target` is optional so that we can write stuff like `entity1.addComponent(RelayComponent(for: entity2.component(ofType: SomeComponent.self)))`
        
        #if LOGECSVERBOSE
        debugLog("targetComponent: \(targetComponent)")
        #endif
        
        self.directlyReferencedComponent = targetComponent
        super.init()
    }
    
    /// Creates a `RelayComponent` which points to a component of the specified type in the scene entity associated with the `SpriteKitComponent` node of this `RelayComponent`'s entity.
    ///
    /// Whenever the `target` of this relay is requested, it will check for `self.entityNode?.scene?.entity?.component(ofType: sceneComponentType)`.
    public init (sceneComponentType: MasterComponentType.Type) {
        
        #if LOGECSVERBOSE
        debugLog("sceneComponentType: \(sceneComponentType)")
        #endif
        
        self.sceneComponentType = sceneComponentType
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func didAddToEntity() {
        super.didAddToEntity()
        
        guard let entity = self.entity else { return }
        
        // Warn if the entity already has the actual component that we're a relay for.
        
        if  let existingComponent = coComponent(MasterComponentType.self, ignoreRelayComponents: true)
        {
            if  existingComponent === target {
                OctopusKit.logForWarnings.add("\(entity) already has \(existingComponent)")
            }   else {
                OctopusKit.logForWarnings.add("\(entity) already has a \(type(of: existingComponent)) component: \(existingComponent)")
            }
        }
    }

    /*
    public override var baseComponent: GKComponent? {
        // CHECK: Include? Will it improve correctness and performance in GKEntity.componentOrRelay(ofType:) or is it unnecessary?
        // THANKS: https://forums.swift.org/u/TellowKrinkle
        // https://forums.swift.org/t/type-information-loss-when-comparing-generic-variables-with-an-array-of-metatypes/30650
        target?.baseComponent // ?? self
    }
    */
    
}

