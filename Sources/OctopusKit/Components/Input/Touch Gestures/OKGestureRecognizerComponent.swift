//
//  OKGestureRecognizerComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/19.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Does it impact performance if each gesture recognizer component is its own delegate? Should `OKScene` be the single `OSGestureRecognizerDelegate`?

import OctopusCore
import SpriteKit
import GameplayKit

/// A base class for components that attach an `OSGestureRecognizer` to the `SKView` of the `SceneComponent` when this component is added to the scene entity.
///
/// By default, there is no action (handler) for the gesture events. To use this component, call `gestureRecognizer.addTarget(_:action:)` to assign your event handlers.
///
/// To allow the simultaneous recognition of multiple gesture types, for example pan and zoom, set `self.gestureRecognizer.delegate = self` and add compatible recognizer types to this component's `compatibleGestureRecognizerTypes` array.
///
/// - Note: On iOS, adding a gesture recognizer to the scene's view may prevent touches from being delivered to the scene and its nodes. To allow gesture-based components to cooperate with touch-based components, set properties such as `gestureRecognizer.cancelsTouchesInView` to `false` for this component.
///
/// **Dependencies:** `SceneComponent`
open class OKGestureRecognizerComponent <GestureRecognizerType> : OKComponent, OSGestureRecognizerDelegate
    where GestureRecognizerType: OSGestureRecognizer
{
        
    open override var requiredComponents: [GKComponent.Type]? {
        [SceneComponent.self]
    }
    
    public fileprivate(set) var gestureRecognizer: GestureRecognizerType // CHECK: Should this be optional?
    
    /// To allow the simultaneous recognition of multiple gesture types, for example pan and pinch, the subclass should set `self.gestureRecognizer.delegate = self` and add compatible recognizer types to this array.
    public var compatibleGestureRecognizerTypes: [OSGestureRecognizer.Type] = []
    
    public override init() {
        self.gestureRecognizer = GestureRecognizerType(target: nil, action: nil)
        super.init()
    }
    
    #if canImport(UIKit)
    public convenience init(cancelsTouchesInView: Bool) {
        self.init()
        self.gestureRecognizer.cancelsTouchesInView = cancelsTouchesInView
    }
    #endif
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    open override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        guard let scene = coComponent(SceneComponent.self)?.scene else {
            OKLog.logForWarnings.debug("\(📜("\(entity) missing SceneComponent — Detaching"))")
            self.removeFromEntity()
            return
        }
        
        guard let view = scene.view else {
            OKLog.logForWarnings.debug("\(📜("\(scene) is not part of a view — Detaching"))")
            self.removeFromEntity()
            return
        }
        
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    open override func willRemoveFromEntity(withNode node: SKNode) {
        super.willRemoveFromEntity(withNode: node)
        
        guard let scene = coComponent(SceneComponent.self)?.scene else {
            OKLog.logForWarnings.debug("\(📜("\(entity) missing SceneComponent — Detaching"))")
            self.removeFromEntity()
            return
        }
        
        guard let view = scene.view else {
            OKLog.logForWarnings.debug("\(📜("\(scene) is not part of a view"))")
            return
        }
        
        // Remove all targets and actions.
        
        gestureRecognizer.removeTarget(nil, action: nil)
        
        view.removeGestureRecognizer(gestureRecognizer)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    open func gestureRecognizer(
        _ gestureRecognizer: OSGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: OSGestureRecognizer)
        -> Bool
    {
        guard
            gestureRecognizer == self.gestureRecognizer,
            otherGestureRecognizer.view == self.gestureRecognizer.view
            else { return false }
        
        // See if this gesture recognizer should handle gestures simultaneously with other recognizers.
        
        return self.compatibleGestureRecognizerTypes.contains { $0 == type(of: otherGestureRecognizer) }
    }
}
