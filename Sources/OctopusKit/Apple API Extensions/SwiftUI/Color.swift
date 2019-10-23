//
//  Color+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/23.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI

public extension SwiftUI.Color {
    
    /// Returns a random `Color` from the list of preset colors (as of 2019/10/23), **excluding** `clear`, `primary`, `secondary` and `accentColor`.
    static var random: Color {
        // NOTE: This must be a COMPUTED property! Assigning a value makes this a static variable, which will always be the first color it got. :)
        [black,
         white,
         gray,
         red,
         green,
         blue,
         orange,
         yellow,
         pink,
         purple]
            .randomElement()!
    }
    
    /// Returns a random `Color` from the list of preset colors (as of 2019/10/23), **excluding** `black`, `white`, `clear`, `primary`, `secondary` and `accentColor`.
    static var randomExcludingBlackWhite: Color {
        // NOTE: This must be a COMPUTED property! Assigning a value makes this a static variable, which will always be the first color it got. :)
        [gray,
         red,
         green,
         blue,
         orange,
         yellow,
         pink,
         purple]
            .randomElement()!
    }
}
