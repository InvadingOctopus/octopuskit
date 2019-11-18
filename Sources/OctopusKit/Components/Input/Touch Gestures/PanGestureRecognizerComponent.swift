//
//  PanGestureRecognizerComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/09.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: macOS compatibility

import SpriteKit
import GameplayKit
//import UIKit

#if os(iOS) // TODO: Add macOS trackpad support.

/// Creates a `UIPanGestureRecognizer` and attaches it to the `SpriteKitSceneComponent` `SKView` when this component is added to the scene entity.
///
/// - Important: The x and y values report the total translation over time. They are not delta values from the last time that the translation was reported. Apply the translation value to the state of the view when the gesture is first recognized — do not concatenate the value each time the handler is called.
///
/// - Note: Adding a gesture recognizer to the scene's view may prevent touches from being delivered to the scene and its nodes. To allow gesture-based components to cooperate with touch-based components, set properties such as `gestureRecognizer.cancelsTouchesInView` to `false` for this component.
///
/// **Dependencies:** `SpriteKitSceneComponent`
public final class PanGestureRecognizerComponent: OctopusGestureRecognizerComponent<UIPanGestureRecognizer> {
    
    // ⚠️ NOTE: https://developer.apple.com/documentation/uikit/uipangesturerecognizer/1621207-translation
    
    /// - NOTE: Unless specified, `maximumNumberOfTouches` will be set equal to `minimumNumberOfTouches`.
    public init(minimumNumberOfTouches: Int = 1,
                maximumNumberOfTouches: Int? = nil,
                cancelsTouchesInView: Bool = true)
    {
        super.init() // CHECK: PERFORMANCE: Is it faster to not call the `super.init(cancelsTouchesInView:)` convenience?
        self.gestureRecognizer.cancelsTouchesInView = cancelsTouchesInView
        self.gestureRecognizer.minimumNumberOfTouches = minimumNumberOfTouches
        self.gestureRecognizer.maximumNumberOfTouches = maximumNumberOfTouches ?? minimumNumberOfTouches
        self.gestureRecognizer.delegate = self
        self.compatibleGestureRecognizerTypes = [UIPinchGestureRecognizer.self]
    }

    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

#endif
    
#if !os(iOS) // TODO: Add macOS trackpad support.
public final class PanGestureRecognizerComponent: iOSExclusiveComponent {}
#endif
