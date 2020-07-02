//
//  MainMenuUI.swift
//  OctopusKit Project Template
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/07/02.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI
import OctopusKit
// import OctopusUI

struct MainMenuUI: View {

    @EnvironmentObject var gameCoordinator: GameCoordinator

    var body: some View {
        VStack {

            title

            Spacer()

            menu.font(.title)

            Spacer()
        }
    }

    var title: some View {
        Text("\(OctopusKit.shared.appName)")
            .fontWeight(.bold)
            .font(.largeTitle)
            .foregroundColor(.primary)
    }

    var menu: some View {
        VStack {
            Button(action: { self.gameCoordinator.enter(PlayState.self) }) {
                Text("START")
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        // .buttonStyle(FatButtonStyle())
        }
    }

}

struct MainMenuUI_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuUI()
            .environmentObject(GameCoordinator())
    }
}

