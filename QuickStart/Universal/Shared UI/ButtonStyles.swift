//
//  OctopusKitQuickStart.swift
//  OctopusUI
//  https://github.com/InvadingOctopus/octopusui
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/3.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// ❕ This code has been copied from the OctopusUI package to simplify the OctopusKit QuickStart tutorial and to keep OctopusKit self-contained (without dependencies on other packages). It may be an older version than its counterpart in OctopusUI.
// ❗️ Exclude this file from your project if you import OctopusUI, otherwise using one of these extensions may cause an ambiguity conflict and prevent compilation.

import SwiftUI

struct FatButtonStyle: ButtonStyle {
    
    var color: Color = .accentColor
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10)
                .foregroundColor(color)
                .opacity(0.85)
                .brightness(configuration.isPressed ? 0.2 : 0)
                .shadow(color: .black,
                        radius: configuration.isPressed ? 5 : 10,
                        x: 0,
                        y: configuration.isPressed ? -2 : -10))
    }
}

/// Preview in live mode to test interactivity and animations.
struct FatButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {}) {
            Text("Fat Button Style")
        }
        .buttonStyle(FatButtonStyle())
        .padding()
        .background(Color.white)
        .previewLayout(.sizeThatFits)
    }
}
