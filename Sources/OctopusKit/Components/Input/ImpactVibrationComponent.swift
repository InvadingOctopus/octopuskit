//
//  ImpactVibrationComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/28.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

#if os(iOS)
    
public final class ImpactVibrationComponent: VibrationComponent<UIImpactFeedbackGenerator> {
    
    public var style: UIImpactFeedbackGenerator.FeedbackStyle
    
    public init(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        self.style = style
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createGenerator() {
        self.feedbackGenerator = UIImpactFeedbackGenerator(style: self.style)
    }
    
    public override func vibrate() {
        self.feedbackGenerator?.impactOccurred()
    }
    
}

#else
    
public final class ImpactVibrationComponent: iOSExclusiveComponent {}
    
#endif
