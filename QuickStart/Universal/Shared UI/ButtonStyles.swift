//
//  OctopusKitQuickStart.swift
//  MacSwiftUISandbox
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/3.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI

struct FatButtonStyle: ButtonStyle {
    
    var color: Color
    
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
            .padding()
    }
}

/// Preview in live mode to test interactivity and animations.
struct ButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ForEach(0..<3) { _ in
                Button(action: {}) {
                    Text("Fat Button Style")
                }
                .buttonStyle(FatButtonStyle(color: .randomExcludingBlackWhite))
            }
        }
        .padding()
        .background(Color.random)
        .previewLayout(.sizeThatFits)
    }
}
