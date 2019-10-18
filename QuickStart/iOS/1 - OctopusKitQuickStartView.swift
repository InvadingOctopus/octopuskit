//
//  OctopusKitQuickStartView.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/16.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 1: A SwiftUI view which displays the OctopusKit QuickStart "game".
//
//  Add this view in the `body` property of your SwiftUI project's `ContentView.swift` file.

import SwiftUI
import OctopusKit
import Combine

struct OctopusKitQuickStartView: View {
    
    var body: some View {
        
        ZStack {
            OctopusKitView<QuickStartGameCoordinator, MyGameViewController>()
            OctopusKitQuickStartUI()
        }
        .environmentObject(QuickStartGameCoordinator())
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
    }
    
}

struct OctopusKitQuickStartUI: View {
    
    @EnvironmentObject var gameCoordinator: QuickStartGameCoordinator
    
    var preview: Bool = false
    
//    var showStateCycleButton: Bool {
//        gameCoordinator.currentGameState != nil
//            && !(gameCoordinator.currentGameState! is LogoState)
//    }
    
    @State var showStateCycleButton: Bool = false
    
    var body: some View {
    
        gameCoordinator.$currentScene
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { (scene) in
                print(scene)
                withAnimation(.spring()) {
                    self.showStateCycleButton = !(scene is OctopusLogoScene)
                }
        }
        
        return ZStack {
            
            if preview { Rectangle().foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.5)) }
            
            if showStateCycleButton {
                
                VStack {
                    
                    Spacer()
                    
                    nextStateButton
                    
                    Text("☝️ This button is a SwiftUI control!")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .opacity(0.9)
                        .padding(5)
                        .background(Rectangle()
                            .foregroundColor(.black)
                            .cornerRadius(5)
                            .opacity(0.6))
                        .padding(.bottom, 15)
                }
                .transition(.move(edge: .bottom))
            }
            
        }
    }
    
    var nextStateButton: some View {
        
        Button(action: nextGameState) {
            
            VStack {
                Text("TAP TO CYCLE GAME STATES")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
            }
            .background(Rectangle()
            .foregroundColor(.accentColor)
            .cornerRadius(10)
            .opacity(0.85)
            .shadow(color: .black, radius: 10, x: 0, y: -10))
            .padding()
        }
    }
    
    func nextGameState() {
        if let currentScene = gameCoordinator.currentScene {
            OctopusKit.logForDebug.add("Next state button tapped!")
            currentScene.octopusSceneDelegate?.octopusSceneDidChooseNextGameState(currentScene)
        }
    }
}

struct COctopusKitQuickStartView_Previews: PreviewProvider {
    static var previews: some View {
        OctopusKitQuickStartUI(preview: true)
    }
}
