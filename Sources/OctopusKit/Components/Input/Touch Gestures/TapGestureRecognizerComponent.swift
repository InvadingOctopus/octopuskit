//
//  TapGestureRecognizerComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/19.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

#if os(iOS) // CHECK: Add tvOS support?

/// Creates a `UITapGestureRecognizer` and attaches it to the `SceneComponent` `SKView` when this component is added to the scene entity.
///
/// - Important: Although taps are discrete gestures, they are discrete for each state of the gesture recognizer; thus the associated action message is sent when the gesture begins and is sent for each intermediate state until (and including) the ending state of the gesture.
///
/// - Note: Adding a gesture recognizer to the scene's view may prevent touches from being delivered to the scene and its nodes. To allow gesture-based components to cooperate with touch-based components, set properties such as `gestureRecognizer.cancelsTouchesInView` to `false` for this component.
///
/// **Dependencies:** `SceneComponent`
@available(iOS 13.0, *)
public final class TapGestureRecognizerComponent: OKGestureRecognizerComponent<UITapGestureRecognizer> {
    
    // ⚠️ NOTE: https://developer.apple.com/documentation/uikit/uitapgesturerecognizer
    
    public init(numberOfTapsRequired:    Int  = 1,
                numberOfTouchesRequired: Int  = 1,
                cancelsTouchesInView:    Bool = true)
    {
        super.init() // CHECK: PERFORMANCE: Is it faster to not call the `super.init(cancelsTouchesInView:)` convenience?
        self.gestureRecognizer.cancelsTouchesInView    = cancelsTouchesInView
        self.gestureRecognizer.numberOfTapsRequired    = numberOfTapsRequired
        self.gestureRecognizer.numberOfTouchesRequired = numberOfTouchesRequired
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

#endif

#if os(macOS)
@available(macOS, unavailable, message: "Use ClickGestureRecognizerComponent")
public final class TapGestureRecognizerComponent: iOSExclusiveComponent {}
#endif
