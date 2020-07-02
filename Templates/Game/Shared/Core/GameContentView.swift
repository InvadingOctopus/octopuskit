//
//  GameContentView.swift
//  OctopusKit Project Template
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/07/02.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI
import OctopusKit

/// Set this as the root view of your SwiftUI project's `ContentView`.
struct GameContentView: View {

    @StateObject private var gameCoordinator = GameCoordinator()

    var body: some View {
        OKContainerView<GameCoordinator, OKViewController>()
            .environmentObject(gameCoordinator)
            .statusBar(hidden: true)
            // .edgesIgnoringSafeArea(.all) // Uncomment this to allow all of your UI views to encompass the entire screen (e.g. including the iPhone notch).
    }
}

struct GameContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameContentView()
    }
}
