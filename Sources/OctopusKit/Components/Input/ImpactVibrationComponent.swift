//
//  ImpactVibrationComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/28.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

#if swift(>=4.2)
// TODO: Remove this temporary alias and incorporate changes into main code after Swift 4.2 launches.
public typealias UIImpactFeedbackStyle = UIImpactFeedbackGenerator.FeedbackStyle
#endif

#if os(iOS)
    
public final class ImpactVibrationComponent: VibrationComponent<UIImpactFeedbackGenerator> {
    
    public var style: UIImpactFeedbackStyle
    
    public init(style: UIImpactFeedbackStyle = .light) {
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
