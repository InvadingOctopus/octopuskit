//
//  TitleUI.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/20.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 5C: The user interface overlay for the QuickStart project.
//
//  This view displays a button which signals the game coordinator to enter the next game state when it's tapped.

import SwiftUI
import OctopusKit

struct TitleUI: View {
    
    @EnvironmentObject var gameCoordinator: MyGameCoordinator
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            nextStateButton
                .buttonStyle(QuickStartButtonStyle(color: .accentColor))
            
            Text("☝️ These buttons are SwiftUI controls!")
                .font(.footnote)
                .foregroundColor(.white)
                .opacity(0.9)
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.black)
                    .opacity(0.6))
                .padding(.bottom, 15)
        }
        //            .transition(.move(edge: .bottom))
        
    }
    
    var nextStateButton: some View {
        
        Button(action: nextGameState) {
            Text("CYCLE GAME STATES")
                .fontWeight(.bold)
        }
    }
    
    func nextGameState() {
        if let currentScene = gameCoordinator.currentScene {
            OctopusKit.logForDebug.add("Next state button tapped!")
            currentScene.octopusSceneDelegate?.octopusSceneDidChooseNextGameState(currentScene)
        }
    }
    
    func changeView() {
        
    }
}

struct TitleUI_Previews: PreviewProvider {
    static var previews: some View {
        TitleUI()
    }
}
