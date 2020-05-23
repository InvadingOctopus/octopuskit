//
//  OctopusKit+Aliases.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020-04-22
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// SEE ALSO: OSAgnosticTypeAliases.swift

// Some cleaner aliases without prefixes for commonly-used types.

// NOTE: STYLE: The engine API should use the original types for specific clarity in cases where the alias may not be immediately clear.

import SpriteKit

/// A closure that takes no arguments and does not return any value.
public typealias Closure           = () -> Void // DESIGN: It's not Closure<T> because this is meant for keeping text clutter to a minimum.

public typealias NonVoidClosure<T> = () -> T

public typealias Vector = CGVector
