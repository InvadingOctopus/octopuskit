//
//  iOSExclusiveComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/21.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

#if os(iOS)

/// A "dummy" base class for components that are not compatible with macOS or tvOS.
public typealias iOSExclusiveComponent = OKComponent
    
#else

/// A "dummy" base class for components that are not compatible with macOS or tvOS.
open class iOSExclusiveComponent: OKComponent {
    
    public override init() {
        // TO DECIDE: Error or warning?
        OKLog.logForErrors.debug("\(type(of: self)) is for iOS only!")
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("\(Self.self)) is for iOS only!") }
}

#endif
