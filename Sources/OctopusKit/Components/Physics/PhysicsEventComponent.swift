//
//  PhysicsEventComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests
// CHECK: Potential 1-frame lag due to `SKScene.update(deltaTime:)` vs `SKPhysicsContactDelegate`?

import GameplayKit

/// Stores events about contacts between physics bodies in a scene. The events may be observed by other components, and are cleared every frame.
///
/// - Note: Unless events are manually forwarded to another entity, this component should be added to an `OKScene.entity` and the `OKScene.physicsWorld.contactDelegate` must be set to the scene. This is automatically done when a `PhysicsWorldComponent` is added to the scene entity.
public final class PhysicsEventComponent: OKComponent, OKUpdatableComponent {
    
    public final class ContactEvent: Equatable {
        
        public let contact: SKPhysicsContact
        public let scene: OKScene? // CHECK: Should this be optional?
        
        public init(contact: SKPhysicsContact,
                    scene: OKScene? = nil)
        {
            self.contact = contact
            self.scene   = scene
        }
        
        public static func == (left: ContactEvent, right: ContactEvent) -> Bool {
            return (left.contact === right.contact
                &&  left.scene === right.scene)
        }
        
        public static func != (left: ContactEvent, right: ContactEvent) -> Bool {
            return (left.contact !== right.contact
                &&  left.scene !== right.scene)
        }
    }
    
    public var contactBeginnings = [ContactEvent]()
    public var contactEndings    = [ContactEvent]()
    
    public fileprivate(set) var clearOnNextUpdate: Bool = false
    
    public override func didAddToEntity() {
        super.didAddToEntity()
        
        guard let scene = self.entity?.node as? SKScene else {
            OctopusKit.logForWarnings("Entity \(self.entity) is not a scene — \(self) may not automatically receive physics events!")
            return
        }
        
        guard scene.physicsWorld.contactDelegate === scene else { // NOTE: The `===` operator.
            OctopusKit.logForWarnings("The scene's physicsWorld.contactDelegate is not set to the scene — \(self) may not automatically receive physics events!")
            OctopusKit.logForTips ("Add a PhysicsWorldComponent to the OKScene.entity")
            return
        }
    }
    
    /// To be called every frame AFTER other components, if any, have had a chance to act upon the stored events during a given frame.
    public override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)

        // Clear the event arrays while maintaining their storage, as they are likely to grow again on the next frame.
        
        if clearOnNextUpdate {
            contactBeginnings.removeAll(keepingCapacity: true)
            contactEndings   .removeAll(keepingCapacity: true)
            clearOnNextUpdate = false
        }
        
        if contactBeginnings.count > 0 || contactEndings.count > 0 {
            clearOnNextUpdate = true
        }
    }
    
    @inlinable
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        contactBeginnings.removeAll(keepingCapacity: false)
        contactEndings   .removeAll(keepingCapacity: false)
    }
    
}
