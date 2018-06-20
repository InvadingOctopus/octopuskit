//
//  PointerEventComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/14.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// ⚠️ Prototype; Incomplete.

// DECIDE: Will constantly copying over events between this component and touch/mouse components be better than simply accessing the touch or mouse event at the point of use in player-controlled components?

import SpriteKit
import GameplayKit

/// A device-agnostic component for relaying player input from pointer-like sources, such as touch or mouse, to other player-controlled components.
public final class PointerEventComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public struct PointerInput: Hashable {
        // TODO: Implement
    }
    
    public final class PointerEvent: Equatable {
        // TODO: Implement
        
        // NOTE: `Equatable` conformance cannot be automatically synthesized by Swift 4.1 for classes
        
        public let pointerInputs: Set<PointerInput>
        
        public var clearOnNextUpdate: Bool = false
        
        public init(pointerInputs: Set<PointerInput>) {
            self.pointerInputs = pointerInputs
        }
        
        public static func == (left: PointerEvent, right: PointerEvent) -> Bool {
            return (left.pointerInputs == right.pointerInputs)
        }
        
    }
    
    public var pointerInputsBegan: PointerEvent?
    public var pointerInputsMoved: PointerEvent?
    public var pointerInputsEnded: PointerEvent?
    
    public override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
    }
}

