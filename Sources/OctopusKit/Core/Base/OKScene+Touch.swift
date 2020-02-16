//
//  OKScene+Touch.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/2.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

#if canImport(UIKit) // Includes tvOS

extension OKScene: TouchEventProvider {
    
    // TODO: Eliminate code duplication between OKScene+Touch and OKSubscene+Touch
    
    // MARK: - Player Input (iOS Touch)
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        self.entity?[TouchEventComponent.self]?.touchesBegan = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
    }
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        self.entity?[TouchEventComponent.self]?.touchesMoved = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
    }
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        self.entity?[TouchEventComponent.self]?.touchesCancelled = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
    }
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        self.entity?[TouchEventComponent.self]?.touchesEnded = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
    }
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    open override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        self.entity?[TouchEventComponent.self]?.touchesEstimatedPropertiesUpdated = TouchEventComponent.TouchEvent(touches: touches, event: nil, node: self)
    }
}

#endif
