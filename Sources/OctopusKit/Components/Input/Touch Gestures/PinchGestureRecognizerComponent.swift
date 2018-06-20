//
//  PinchGestureRecognizerComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/19.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

#if os(iOS)

/// Creates a `UIPinchGestureRecognizer` and attaches it to the `SpriteKitSceneComponent` `SKView` when this component is added to the scene entity.
///
/// When the player moves the two fingers toward each other, the conventional meaning is zoom-out; when the player moves the two fingers away from each other, the conventional meaning is zoom-in.
///
/// Pinching is a continuous gesture. The gesture begins (began) when the two touches have moved enough to be considered a pinch gesture. The gesture changes (changed) when a finger moves (with both fingers remaining pressed). The gesture ends (ended) when both fingers lift from the view.
///
/// - Important: The scale value is an absolute value that varies over time. It is not the delta value from the last time that the scale was reported. Apply the scale value to the state of the view when the gesture is first recognized—do not concatenate the value each time the handler is called.
///
/// - Note: Adding a gesture recognizer to the scene's view may prevent touches from being delivered to the scene and its nodes. To allow gesture-based components to cooperate with touch-based components, set properties such as `gestureRecognizer.cancelsTouchesInView` to `false` for this component.
///
/// **Dependencies:** `SpriteKitSceneComponent`
public final class PinchGestureRecognizerComponent: OctopusGestureRecognizerComponent<UIPinchGestureRecognizer> {
    
    // ⚠️ NOTE: https://developer.apple.com/documentation/uikit/uipinchgesturerecognizer/1622235-scale
    
    public init(cancelsTouchesInView: Bool = true) {
        super.init() // CHECK: PERFORMANCE: Is it faster to not call the `super.init(cancelsTouchesInView:)` convenience?
        self.gestureRecognizer.cancelsTouchesInView = cancelsTouchesInView
        self.gestureRecognizer.delegate = self
        self.compatibleGestureRecognizerTypes = [UIPanGestureRecognizer.self]
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

#else

public final class PinchGestureRecognizerComponent: iOSExclusiveComponent {}

#endif
