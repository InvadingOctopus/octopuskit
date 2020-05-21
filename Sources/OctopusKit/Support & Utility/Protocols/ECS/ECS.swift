//
//  ECS.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/21.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation
import GameplayKit

// MARK: - Common

public protocol UpdatablePerFrame {
    func update(deltaTime seconds: TimeInterval)
}

