//
//  PlayUI.swift
//  OctopusKit Project Template
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/07/02.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI
import OctopusKit

struct PlayUI: View {

    var viewModelComponent: UIViewModelComponent? {
        OctopusKit.shared.currentScene?.entity?[UIViewModelComponent.self]
    }

    var body: some View {
        VStack {

            if  let viewModelComponent = self.viewModelComponent {
                PlayerStatsView()
                    .environmentObject(viewModelComponent)
                    .font(.title)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
    }
}

struct PlayUI_Previews: PreviewProvider {
    static var previews: some View {
        PlayUI()
    }
}
