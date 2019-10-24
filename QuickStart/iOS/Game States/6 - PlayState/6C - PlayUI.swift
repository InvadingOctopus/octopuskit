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
                    .blendMode(.hardLight)
                
                Text("""
                    Tap and drag on the background to spawn physics entities.

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
            
            TitleUI(suppressAppearanceAnimation: true)
        }
    }
    
}

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
    
    var body: some View {
        Text(stateName)
            .fontWeight(.bold)
            .font(Font(UIFont(name: "AvenirNextCondensed-Bold", size: 25)!))
            .foregroundColor(.white)
            .shadow(color: .white, radius: 10, x: 0, y: 0)
    }
}

struct GlobalDataComponentLabel: View {
    
    @ObservedObject var component: GlobalDataComponent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Global Data Component")
                .font(.headline)
                .foregroundColor(.black)
            Text("(persists across states and scenes)")
                .font(.footnote)
                .foregroundColor(.black)
            Text("""
                Seconds since activation: \(component.secondsElapsedTrimmed)
                Emojis spawned: \(component.emojiCount)
                """)
                .fontWeight(.bold)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.accentColor)
            .shadow(radius: 10))
    }
}

struct PlayUI_Previews: PreviewProvider {
    static var previews: some View {
        
        let gameCoordinator = MyGameCoordinator()
        gameCoordinator.entity.addComponent(GlobalDataComponent())
        
        return PlayUI()
            .environmentObject(gameCoordinator)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.red)
            .background(Color(red: 0.1, green: 0.2, blue: 0.2))
            .edgesIgnoringSafeArea(.all)
    }
}