//
//  PlayUI.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/23.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 6C: The user interface overlay for PlayState, PausedState and GameOverState.
//
//  Once you understand how everything works, you may delete this file and replace it with your own UI.

import SwiftUI
import OctopusKit

struct PlayUI: View {
    
    @EnvironmentObject var gameCoordinator:  MyGameCoordinator
    
    /// Hides the UI on tvOS so that it doesn't intercept remote input from the gameplay.
    private var showUI: Bool {
        #if os(tvOS)
        return !(gameCoordinator.currentGameState is PlayState)
        #else
        return true
        #endif
    }
    
    private var globalDataComponent: GlobalDataComponent? {
        gameCoordinator.entity.component(ofType: GlobalDataComponent.self)
    }
    
    let instructions: String = {
        #if os(macOS)
        let systemDependentText = "Click and drag on the background to spawn physics entities in PlayState."
        #elseif os(tvOS)
        let systemDependentText = "Slide on the remote to spawn physics entities in PlayState. Press the Play/Pause button to view the UI."
        #else
        let systemDependentText = "Tap and drag on the background to spawn physics entities in PlayState."
        #endif
        
        return systemDependentText + "\n\nThe text and UI is a SwiftUI overlay on top of a SpriteKit view."
    }()
    
    var body: some View {
        VStack {
            
            VStack(spacing: 20) {
                
                GameStateLabel().padding(.top, 50)
                    .opacity(0.9)
                    .blendMode(.lighten)
                
                Text(instructions)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .blendMode(.difference)
                
                Spacer()
                
                if  showUI && globalDataComponent != nil {
                    GlobalDataComponentLabel(component: globalDataComponent!)
                        .opacity(0.8)
                }
                
                Spacer()
            }
            .frame(alignment: .top)
            .padding()
            
            if  showUI {
                cycleStateButton
            }
        }
        .tvOSExcluded { $0.padding(.bottom, 50) }
        .tvOS { $0.padding(.bottom, 100) } // BUG? APPLEBUG? This seems necessary to prevent the bottom edge of the button from stretching.
    }
    
    var cycleStateButton: some View {
        Button(action: cycleGameState) {
            Text("CYCLE GAME STATES")
                .fontWeight(.bold)
        }
        .tvOSExcluded { $0.buttonStyle(FatButtonStyle(color: .purple)) }
    }
    
    func cycleGameState() {
        if  let currentScene = gameCoordinator.currentScene {
            currentScene.octopusSceneDelegate?.octopusSceneDidChooseNextGameState(currentScene)
        }
    }
    
}

/// Displays the name of the current game state.
struct GameStateLabel: View {
    
    @EnvironmentObject var gameCoordinator:  MyGameCoordinator
    
    var stateName: String {
        switch gameCoordinator.currentState {
        case is LogoState:      return "LogoState"
        case is TitleState:     return "TitleState"
        case is PlayState:      return "PlayState"
        case is PausedState:    return "PausedState"
        case is GameOverState:  return "GameOverState"
        default:                return "[unknown state]"
        }
    }
    
    var stateColor: Color {
        switch gameCoordinator.currentState {
        case is LogoState:      return .blue
        case is TitleState:     return .white
        case is PlayState:      return .green
        case is PausedState:    return .orange
        case is GameOverState:  return .red
        default:                return .gray
        }
    }
    
    var body: some View {
        Text(stateName)
            .fontWeight(.bold)
            .tvOSExcluded { $0.font(Font(OSFont(name: "AvenirNextCondensed-Bold", size: 25)!)) }
            .shadow(color: stateColor, radius: 10, x: 0, y: 0)
    }
}

/// Displays data from the `GlobalDataComponent` which is part of the `MyGameCoordinator.entity` and remains active across all states and scenes.
struct GlobalDataComponentLabel: View {
    
    @ObservedObject var component: GlobalDataComponent
    
    var color = Color.randomExcludingBlackWhite
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Global Data Component")
                .font(.headline)
                .foregroundColor(.black)
            Text("Persists across states and scenes")
                .font(.callout)
                .foregroundColor(.black)
            Text("""
                Seconds since activation: \(component.secondsElapsedRounded)
                Emojis spawned: \(component.emojiCount)
                High Score: \(component.emojiHighScore)
                """)
                .fontWeight(.bold)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.white)
            Text("Score saved as a user preference that persists across app launches")
                .font(.callout)
                .foregroundColor(.black)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10)
            .foregroundColor(color)
            .shadow(radius: 10))
    }
}

// MARK: - Preview

struct PlayUI_Previews: PreviewProvider {
    
    static let gameCoordinator = MyGameCoordinator()
    
    static var previews: some View {
        gameCoordinator.entity.addComponent(GlobalDataComponent())
        
        return PlayUI()
            .environmentObject(gameCoordinator)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.red)
            .background(Color(red: 0.1, green: 0.2, blue: 0.2))
            .edgesIgnoringSafeArea(.all)
    }
}
