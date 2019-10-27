//
//  PlayUI.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/23.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 5C: The user interface overlay for the PlayState.
//
//  As you can see, PlayUI includes TitleUI. The power of SwiftUI makes it very easy to compose user interfaces from different self-contained parts.

import SwiftUI
import OctopusKit

struct PlayUI: View {
    
    @EnvironmentObject var gameCoordinator:  MyGameCoordinator
    
    private var globalDataComponent: GlobalDataComponent? {
        gameCoordinator.entity.component(ofType: GlobalDataComponent.self)
    }
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 20) {
                
                GameStateLabel().padding(.top, 40)
                    .opacity(0.9)
                    .blendMode(.lighten)
                
                Text("""
                    Tap and drag on the background to spawn physics entities in PlayState.

                    All this text and UI is a SwiftUI overlay on top of a SpriteKit view, all powered by Metal.
                    """)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .blendMode(.difference)
                
                Spacer()
                
                GlobalDataComponentLabel(component: globalDataComponent!)
                    .opacity(0.8)
                
                Spacer()
            }
            .frame(alignment: .top)
            .padding()
            
            // Include the TitleUI in its entirety as a child view of PlayUI, so we don't have to recreate its contents here.
            
            TitleUI()
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
            .font(Font(UIFont(name: "AvenirNextCondensed-Bold", size: 25)!))
            .foregroundColor(stateColor)
            .shadow(color: stateColor, radius: 10, x: 0, y: 0)
    }
}

/// Displays data from the `GlobalDataComponent` which is part of the `MyGameCoordinator.entity` and remains active across all states and scenes.
struct GlobalDataComponentLabel: View {
    
    @ObservedObject var component: GlobalDataComponent

    @State private var color = Color.green
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Global Data Component")
                .font(.headline)
                .foregroundColor(.black)
            Text("Persists across states and scenes")
                .font(.callout)
                .foregroundColor(.black)
            Text("""
                Seconds since activation: \(component.secondsElapsedTrimmed)
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
        .onTapGesture {
            withAnimation {
                var newColor = self.color
                repeat {
                    newColor = .randomExcludingBlackWhite
                } while newColor == self.color
                self.color = newColor
            }
        }
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
