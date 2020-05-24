//
//  NodeAttachmentComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/14.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

public typealias SpriteKitAttachmentComponent = NodeAttachmentComponent

/// The base class for components that create and add a child node to their entity's primary `NodeComponent` node.
///
/// For example, a UI overlay on a base sprite or even sound effects. When this component is removed from an entity, it also removes the attached node(s) from the parent. To add multiple nodes, use the `SKNode(children:)` construction, as adding multiple components of the same type to an entity is not supported by GameplayKit.
///
/// **Dependencies:** `NodeComponent`
open class NodeAttachmentComponent <AttachmentType> : OKComponent
    where AttachmentType: SKNode
{
    
    // 💡 To use, simply subclass with the appropriate generic type, and implement (override) `createAttachment(for:)`.
    
    open override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self]
    }
    
    /// The child node to add to the parent node specified by the entity's `NodeComponent`. Subclasses of this component may create this node during `createAttachment(for:)`.
    ///
    /// Takes effect only when this component is added to an entity, during `didAddToEntity(withNode:)`.
    public var attachment: AttachmentType?
    
    /// Optionally specifies a different parent node other than the entity's primary node, to add the child attachment to.
    ///
    /// Takes effect only when this component is added to an entity, during `didAddToEntity(withNode:)`.
    public var parentOverride: SKNode?

    /// Optionally specifies an offset to apply to the attachment's position.
    ///
    /// Takes effect only when this component is added to an entity, during `didAddToEntity(withNode:)`.
    public var positionOffset: CGPoint?
    
    /// Optionally specifies a z-position to apply to the attachment.
    ///
    /// Takes effect only when this component is added to an entity, during `didAddToEntity(withNode:)`.
    public var zPositionOverride: CGFloat?
    
    // MARK: - Initialization
    
    public init(_ attachment:       AttachmentType? = nil,
                parentOverride:     SKNode?         = nil,
                positionOffset:     CGPoint?        = nil,
                zPositionOverride:  CGFloat?        = nil)
    {
        self.attachment         = attachment
        self.parentOverride     = parentOverride
        self.positionOffset     = positionOffset
        self.zPositionOverride  = zPositionOverride
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.parentOverride = nil
        super.init()
//        super.init(coder: aDecoder) // Crashes
//        fatalError("init(coder:) has not been implemented")
    }
    
    /// `super` must be called by overriding subclass for proper functionality. Adds `attachment` as a child of the `node` specified by the `NodeComponent`.
    open override func didAddToEntity(withNode node: SKNode) {
        OctopusKit.logForComponents("\(node) ← \(attachment)")
        
        // Warn if the overridden parent is not a child of this component's entity's node.
        
        // CHECK: Warning necessary?
        
        if  let parentOverride = self.parentOverride,
            !node.children.contains(parentOverride)
            && parentOverride != node // Skip warning if the `parentOverride` IS the node. This will be the case in situations like `parentOverride = scene.camera ?? scene` where a child node is added to a scene's camera if there is one, otherwise to the scene itself.
        {
            OctopusKit.logForWarnings("The specified parentOverride \(parentOverride) is not a child of \(entity)'s node: \(node)")
        }
        
        // Allow the subclass to conveniently create an attachment by simply overriding `createAttachment(for:)`.
        
        // ⚠️ NOTE: By writing `?? self.attachment` we take care not to let an unimplemented `createAttachment(for:)` method destroy an existing `attachment` by returning `nil`. The subclass may set `attachment` by other means, such as direct assignment.
        
        self.attachment = createAttachment(for: self.parentOverride ?? node) ?? self.attachment
        
        // Add the attachment to the the `parentOverride` if any has been specified, or the primary node of this component's entity.
        
        addAttachment(to: self.parentOverride ?? node)
    }
    
    // MARK: Attachment
    
    /// Abstract; to be overridden by subclass. `didAddToEntity(withNode:)` calls this method and sets this component's `attachment` to its return value. If this method is not implemented by the subclass, then `didAddToEntity(withNode:)` will not replace any existing `attachment` with `nil`.
    @inlinable
    open func createAttachment(for parent: SKNode) -> AttachmentType? {
        return nil // CHECK: Should this be a `fatalError` if unimplemented?
    }
    
    /// Recreates the `attachment` for its current parent, if any.
    ///
    /// Sets `attachment` to `nil` then calls `createAttachment(for:)` with the previous parent of `attachment`.
    @inlinable
    open func recreateAttachmentForCurrentParent() {
        
        // Make sure we have a parent to begin with.
        
        guard let currentParent = self.attachment?.parent else {
            OctopusKit.logForErrors("\(String(describing: self.attachment)) has no current parent")
            return
        }
        
        // Remove any previous contents.
        
        self.attachment?.removeFromParent()
        self.attachment = nil
        
        // Regenerate new contents for our current parent.
        
        guard let newAttachment = createAttachment(for: currentParent) else {
            OctopusKit.logForErrors("Could not create attachment for \(currentParent)")
            return
        }
        
        currentParent.addChild(newAttachment)
        self.attachment = newAttachment
    }

    @inlinable
    open func addAttachment(to targetParent: SKNode) {
        
        guard let attachment = self.attachment else {
            OctopusKit.logForWarnings("\(self) missing attachment")
            return
        }
        
        // Nothing to do if the attachment is already with the target parent.
        
        guard attachment.parent != targetParent else {
            // CHECK: Apply `positionOffset` even if `attachment` is already in `targetParent`?
            OctopusKit.logForDebug("\(attachment) already a child of \(targetParent)")
            return
        }
        
        // If the attachment is already the child of a different parent, warn and move the attachment over to our target.
        
        if  let existingParent = attachment.parent,
            existingParent !== targetParent
        {
            OctopusKit.logForWarnings("\(attachment) already has a different parent: \(existingParent) — Moving to \(String(describing: entity))'s NodeComponent node: \(targetParent)")
            
            attachment.removeFromParent() // ℹ️ DESIGN: Snatch the attachment from its existing parent, as that would be the expected behavior of adding this component.
        }
        
        // Apply the position offset and z-position override, if specified.
        
        if  let positionOffset = self.positionOffset {
            attachment.position += positionOffset
        }
        
        if  let zPositionOverride = self.zPositionOverride {
            attachment.zPosition = zPositionOverride
        }
        
        targetParent.addChild(attachment)
        
    }
    
    // MARK: - Removal
    
    /// `super` must be called by overriding subclass for proper functionality. Removes `attachment` from its parent.
    open override func willRemoveFromEntity(withNode node: SKNode) {
        guard
            let attachment = self.attachment,
            attachment.parent != nil
            else { return }
        
        OctopusKit.logForComponents("\(node) ~ \(attachment)")
        
        // If a separate parent was not specified, assume the entity's `NodeComponent` node to be the rightful parent.
        let parent = self.parentOverride ?? node
        
        if  attachment.parent !== parent {
            OctopusKit.logForWarnings("\(attachment) was not a child of \(parent) — Removing from \(attachment.parent)")
        }
        
        // Since the removal of a component carries the expectation that the component's behavior will no longer be present, remove the attachment from any parent, even if the parent wasn't the expected node.
        // CHECK: Should the attachment not be removed from a different parent?
        attachment.removeFromParent()
        
    }
    
    deinit {
        if  shouldRemoveFromEntityOnDeinit {
            attachment?.removeFromParent()
        }
    }
}
