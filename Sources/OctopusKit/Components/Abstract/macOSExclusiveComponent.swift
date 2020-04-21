//
//  macOSExclusiveComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/2.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

#if os(macOS)

/// A "dummy" base class for components that are not compatible with iOS.
public typealias macOSExclusiveComponent = OKComponent
    
#else

/// A "dummy" base class for components that are not compatible with iOS.
open class macOSExclusiveComponent: OKComponent {
    
    public override init() {
        // TO DECIDE: Error or warning?
        OctopusKit.logForErrors("\(type(of: self)) is for macOS only!")
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("\(Self.self)) is for macOS only!") }
}

#endif
