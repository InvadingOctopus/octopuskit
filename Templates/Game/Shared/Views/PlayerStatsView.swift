//
//  PlayerStatsView.swift
//  OctopusKit Project Template
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/07/02.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI

struct PlayerStatsView: View {

    @EnvironmentObject var viewModelComponent: UIViewModelComponent

    var body: some View {
        VStack {
            Text("Score: \(viewModelComponent.playerScore)")
            Text("Angle: \(viewModelComponent.playerRotation)")
        }
        .foregroundColor(.accentColor)
    }
}

struct PlayerStatsView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerStatsView()
            .environmentObject(UIViewModelComponent())
    }
}
