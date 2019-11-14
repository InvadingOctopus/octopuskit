//
//  OctopusScene+Touch.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/2.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//


import SpriteKit

#if canImport(UIKit) // CHECK: Include tvOS?

extension OctopusScene: TouchEventProvider {
    
    // TODO: Eliminate code duplication between OctopusScene+Touch and OctopusSubscene+Touch
    
    // MARK: - Player Input (iOS Touch)
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesBegan = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
        }
    }
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesMoved = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
        }
    }
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesCancelled = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
        }
    }
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesEnded = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
        }
    }
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    open override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesEstimatedPropertiesUpdated = TouchEventComponent.TouchEvent(touches: touches, event: nil, node: self)
        }
    }
}

#endif
