//
//  Orientations.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/28.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

public typealias OctopusOrientation = OKOrientation
public enum OKOrientation {
    case horizontal, vertical
}

public typealias OctopusHorizontalOrientation = OKHorizontalOrientation
public enum OKHorizontalOrientation {
    case left, right
}

public typealias OctopusVerticalOrientation = OKVerticalOrientation
public enum OKVerticalOrientation {
    case up, down
}
