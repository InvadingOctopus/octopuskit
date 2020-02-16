//
//  TitleUI.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/20.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 5C: The user interface overlay for the title screen of the QuickStart project.
//
//  This view displays a button which signals the game coordinator to enter the next playable game state.
//
//  Once you understand how everything works, you may delete this file and replace it with your own UI.

import SwiftUI
import OctopusKit

struct TitleUI: View {
    
    @EnvironmentObject var gameCoordinator: MyGameCoordinator
    
    var body: some View {
        
        VStack {
            Spacer()
            startButton
        }
        .tvOSExcluded { $0.padding(.bottom, 50) }
        .tvOS { $0.padding(.bottom, 100) } // BUG? APPLEBUG? This seems necessary to prevent the bottom edge of the button from stretching.
    }
    
    var startButton: some View {
        Button(action: startGame) {
            Text("START").fontWeight(.bold)
        }
        .tvOSExcluded { $0.buttonStyle(FatButtonStyle(color: .green)) }
    }
    
    func startGame() {
        gameCoordinator.enter(PlayState.self)
    }
}

// MARK: - Preview

struct TitleUI_Previews: PreviewProvider {
    static var previews: some View {
        TitleUI()
            .environmentObject(MyGameCoordinator())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.red)
            .background(Color(red: 0.2, green: 0.1, blue: 0.5))
            .edgesIgnoringSafeArea(.all)
    }
}
