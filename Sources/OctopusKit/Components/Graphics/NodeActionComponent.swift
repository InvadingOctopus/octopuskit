//
//  NodeActionComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/06.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import OctopusCore
import SpriteKit
import GameplayKit

public typealias SpriteKitActionComponent = NodeActionComponent

/// Adds an action to the entity's `NodeComponent` node with an automatically generated `key`, and removes any action associated with that key when this component is removed from that entity.
///
/// **Dependencies:** `NodeComponent`
public class NodeActionComponent: OKComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self]
    }
    
    public let action: SKAction
    public let key: String
    
    public init(action: SKAction) {
        self.action = action
        self.key = "\(NodeActionComponent.self)\(action.debugDescription)@\(Date().timeIntervalSince1970)"
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func didAddToEntity(withNode node: SKNode) {
        
        if let action = node.action(forKey: key) {
            OKLog.warnings.debug("\(📜("\(node) already has \(action) with key \"\(key)\" — Replacing"))")
            node.removeAction(forKey: key)
        }
        
        node.run(action, withKey: key)
    }
    
    public override func willRemoveFromEntity(withNode node: SKNode) {
        
        if node.action(forKey: key) == nil {
            OKLog.warnings.debug("\(📜("\(node) has no action with key \"\(key)\""))")
        }
        else {
            node.removeAction(forKey: key)
        }
    }
}
