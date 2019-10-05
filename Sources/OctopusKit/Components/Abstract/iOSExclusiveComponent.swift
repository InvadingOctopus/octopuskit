//
//  iOSExclusiveComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/21.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

#if os(iOS)

/// A "dummy" base class for components that are not compatible with macOS.
public typealias iOSExclusiveComponent = OctopusComponent
    
#else

/// A "dummy" base class for components that are not compatible with macOS.
open class iOSExclusiveComponent: OctopusComponent {
    
    public override init() {
        OctopusKit.logForErrors.add("iOS only!")
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

#endif
