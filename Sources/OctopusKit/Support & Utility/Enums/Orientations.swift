//
//  Orientations.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

public typealias OctopusOrientation = OKOrientation
public enum OKOrientation: CaseIterable {
    // CHECK: Should these have associated values? e.g. `.horizontal(.left)`
    case horizontal, vertical
}

public typealias OctopusHorizontalOrientation = OKHorizontalOrientation
public enum OKHorizontalOrientation: CaseIterable {
    case left, right
}

public typealias OctopusVerticalOrientation = OKVerticalOrientation
public enum OKVerticalOrientation: CaseIterable {
    case up, down
}
