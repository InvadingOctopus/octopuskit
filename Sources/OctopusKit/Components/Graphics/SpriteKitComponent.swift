//
//  SpriteKitComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/09.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Should these `init`s be `convenience`? If not, then we get "'required' initializer 'init(coder:)' must be provided by subclass of 'GKSKNodeComponent'"

import GameplayKit

/// A component that manages a SpriteKit node and provides the primary visual representation for entities.
///
/// - IMPORTANT: As a temporary fix for APPLEBUG 20180515a, the `isPaused` property of the node is set to `false` when this component is added to an entity.
public final class SpriteKitComponent: GKSKNodeComponent {
    
    @inlinable
    public override var description: String {
        // NOTE: To reduce log clutter, only include the node's name here; full node description should only be in `didAddToEntity()`.
        if  let name = super.node.name {
            return "\(super.description) \"\(name)\""
        } else {
            return  "\(super.description) \(super.node)"
        }
    }
    
    public var shouldNotifyCoComponentsWhenAddedToEntity: Bool = true
    
    // MARK: - Life Cycle
    
    /// Creates a `SpriteKitComponent` with a new, empty `SKNode`.
    public convenience override init() {
        // CHECK: Should there be an empty `init()`? We may want the `node` parameter to be explicit at every `SpriteKitComponent` creation point, because the use of `SpriteKitComponent()` might imply that this component should adopt the `entity.node` (though a `GKSKNodeComponent` must be initialized with an `SKNode`)
        self.init(node: SKNode(), addToNode: nil)
    }
    
    public convenience init(node: SKNode,
                            addToNode newParent: SKNode? = nil,
                            shouldNotifyCoComponentsWhenAddedToEntity: Bool = true)
    {
        self.init(node: node, addToNode: newParent)
        self.shouldNotifyCoComponentsWhenAddedToEntity = shouldNotifyCoComponentsWhenAddedToEntity
    }
    
    public convenience init(createNewNodeIn parent: SKNode,
                            position: CGPoint = CGPoint.zero,
                            zPosition: CGFloat = 0,
                            shouldNotifyCoComponentsWhenAddedToEntity: Bool = true)
    {
        self.init(createNewNodeIn: parent,
                  position: position,
                  zPosition: zPosition)
        self.shouldNotifyCoComponentsWhenAddedToEntity = shouldNotifyCoComponentsWhenAddedToEntity
    }
    
    public override func didAddToEntity() {
        OctopusKit.logForComponents.add("\(entity) ← \(self) \(super.node)")
        
        // Does our node already has a different entity? Check this before calling `super` which may set the node's `entity` property to ours.
        
        if  let entity = self.entity,
            let nodeEntity = self.node.entity,
            nodeEntity !== entity
        {
            OctopusKit.logForWarnings.add("\(self.node)'s entity is \(nodeEntity), but \(self)'s entity is \(self.entity)")
        }
        
        super.didAddToEntity()
        
        // Copy the name if either the entity or the node has a name but the other doesn't.
        
        // CHECK: Will copying names like this aid in logging etc. or will it hinder searches for nodes/entities?
        
        if  let octopusEntity = entity as? OKEntity {
            if  self.node.name == nil
                && octopusEntity.name != nil
            {
                self.node.name = octopusEntity.name
            }
            else if octopusEntity.name == nil
                && self.node.name != nil
            {
                octopusEntity.name = self.node.name
            }
        }
        
        // Inform co-components that their entity now has a visual representation.
        
        if  shouldNotifyCoComponentsWhenAddedToEntity {
            notifyCoComponents()
        }
        
        // ⚠️ BUG: APPLEBUG: 20180515a: Nodes added via an `SKReferenceNode` that is loaded from a scene created in the Xcode Scene Editor, start with their `isPaused` set to `true` until Xcode pauses and resumes the program execution.
        // THANKS: https://stackoverflow.com/questions/47615847/xcode-9-1-and-9-2-referenced-sprites-are-not-executing-actions-added-in-scen
        // TODO: FIXME: Remove this when the bug is fixed.
        
        node.isPaused = false
        
    }
    
    /// Notifies all other existing components of the entity that a `SpriteKitComponent` was added, so they can add their content, if any, to the node.
    ///
    /// This is useful for the case when other components that depend on a `SpriteKitComponent` were added to an entity before this component.
    @inlinable
    public func notifyCoComponents() {
        // CHECK: Should this be `[file]private`?
        guard let entity = self.entity else { return }
        
        for component in entity.components {
            if  let octopusComponent = component as? OKComponent {
                octopusComponent.didAddToEntity(withNode: super.node)
            }
        }
    }
    
    public override func willRemoveFromEntity() {
        OctopusKit.logForComponents.add("\(entity) ~ \(self) \(super.node)")
        
        // Warn if our node somehow ended up in a different entity by now. Check this before calling `super` which may set the node's `entity` property to `nil`.
        
        if  let entity = self.entity,
            let nodeEntity = self.node.entity,
            nodeEntity !== entity
        {
            OctopusKit.logForWarnings.add("\(self.node)'s entity is \(nodeEntity), but \(self)'s entity is \(self.entity)")
        }
        
        super.willRemoveFromEntity()
        
        // No matter which entity the node is in, removing this component should cause the node to be visually removed as well. Right?
        
        super.node.removeAllActions() // CHECK: Necessary?
        
        // NOTE: Do not remove the node's children here, as adding them to the node may have taken a lot of work, and in any case they should be left in a state as to be readily added to an entity or scene again.
        
        if  super.node.parent != nil {
            super.node.removeFromParent()
        }
    }
    
    deinit {
        // Since GameplayKit will remove an existing component from an entity if another component of the same class is added, the `willRemoveFromEntity()` method of the `SpriteKitComponent` or `GKSKNodeComponent` will never be called, because the older component will go straight to `deinit`.
        // Therefore, as that behavior will cause a `SpriteKitComponent` to be removed from an entity WITHOUT removing the represented SpriteKit node from the scene, we should also remove the node here to make sure it is not visible when this component is replaced.
        // For `OKComponent` subclasses, use the `shouldRemoveFromEntityOnDeinit` flag.
        
        if super.node.parent != nil {
            OctopusKit.logForDeinits.add("\(self) \(super.node) ~ Removing from \(super.node.parent!)")
            super.node.removeFromParent()
        }
        else {
            OctopusKit.logForDeinits.add("\(self) \(super.node)")
        }
    }
    
}
