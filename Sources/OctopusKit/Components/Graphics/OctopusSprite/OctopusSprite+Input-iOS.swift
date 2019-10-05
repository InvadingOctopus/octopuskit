//
//  OctopusSpritee+Input-iOS.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/16.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

#if os(iOS)

extension OctopusSprite: TouchEventComponentCompatible {
    
    /// `super` must be called when overriding, to ensure proper operation.
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesBegan = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
        }
    }
    
    /// `super` must be called when overriding, to ensure proper operation.
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesMoved = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
        }
    }
    
    /// `super` must be called when overriding, to ensure proper operation.
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesCancelled = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
        }
    }
    
    /// `super` must be called when overriding, to ensure proper operation.
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesEnded = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
        }
    }
    
    /// `super` must be called when overriding, to ensure proper operation.
    public override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesEstimatedPropertiesUpdated = TouchEventComponent.TouchEvent(touches: touches, event: nil, node: self)
        }
    }
    
}

#endif
