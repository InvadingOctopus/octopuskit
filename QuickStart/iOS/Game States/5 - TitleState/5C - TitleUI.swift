//
//  TitleUI.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/20.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 5C: The user interface overlay for the title screen of the QuickStart project.
//
//  This view displays a button which signals the game coordinator to enter the next game state, along with a few other superficial controls as a HUD example.
//
//  To demonstrate the power and flexibility of SwiftUI, TitleUI is also used as a child view of PlayUI, so the same set of controls can be presented in other game states without having to rewrite the same code.
//
//  ❕ This file may seem moderately complex because of the custom views and animations. Once you understand how everything works, you may delete this file and replace it with your own UI.

import SwiftUI
import OctopusKit

struct TitleUI: View {
    
    @EnvironmentObject var gameCoordinator: MyGameCoordinator
    
    /// This flag is set whenever TitleUI is presented, to display an initial animation.
    @State private var didAppear = false

    /// This flag is used to prevent the on-appearance animation after TitleUI is presented as a child of PlayUI.
    static var suppressAppearanceAnimation = false
    
    /// This flag controls the display of superficial UI for demonstration.
    @State private var showHUD = TitleUI.showHUDGlobal {
        didSet {
            TitleUI.showHUDGlobal = showHUD
        }
    }
    
    /// Since TitleUI is also used in PlayUI, we copy the showHUD setting to a static variable which persists across multiple game states, otherwise it would get reset when the game state changes.
    static var showHUDGlobal = false
        
    /// This flag is set to `false` after the HUD is shown, to prevent it from reanimating when TitleUI is shown inside PlayUI after the game state changes.
    @State private var animateHUDAppearance = true
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            hudUI
            
            Spacer()
            
            // We wrap the buttons in a condition so they can be animated.
            
            if didAppear || TitleUI.suppressAppearanceAnimation {
                
                mainButtons
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom))
                    .animation(.spring(dampingFraction: 0.5))
                    .onAppear {
                        // Prevent animations after the first appearance, otherwise it will reanimate when TitleUI is used by PlayUI.
                        TitleUI.suppressAppearanceAnimation = true
                }
            }
        }
        .onAppear {
            self.didAppear = true // Set a flag to start the initial animation.
            self.showHUD = TitleUI.showHUDGlobal // Sync the instance and global flags.
        }
        
    }
    
    // MARK: - Main Buttons
    // To cycle the game state and display demo UI.
    //
    // Note that the subviews are all instance variables instead of standalone struct types, as they are only used inside TitleUI.
    
    var mainButtons: some View {
        
        VStack {
            
            toggleHUDButton
            
            nextStateButton
            
            Text("👆 These buttons are SwiftUI controls!")
                .font(.footnote)
                .foregroundColor(.white)
                .opacity(0.9)
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.black)
                    .opacity(0.6))
                .padding(.bottom, 15)
        }
    }
    
    var nextStateButton: some View {
        Button(action: nextGameState) {
            QuickStartButtonLabel(text: "CYCLE GAME STATES", color: .accentColor)
        }
    }
    
    var toggleHUDButton: some View {
        Button(action: toggleHUD) {
            QuickStartButtonLabel(text: "TOGGLE MORE UI", color: .purple)
        }
    }
    
    // MARK: - Button Actions
    
    func nextGameState() {
        if let currentScene = gameCoordinator.currentScene {
            OctopusKit.logForDebug.add("Next state button tapped!")
            currentScene.octopusSceneDelegate?.octopusSceneDidChooseNextGameState(currentScene)
        }
    }
    
    func toggleHUD() {
        showHUD.toggle()
    }
    
    // MARK: - Superficial UI
    // To demonstrate animation and HUD overlays.
    
    var hudUI: some View {
        
        HStack(alignment: .center) {
            
            if showHUD || TitleUI.showHUDGlobal {
                
                hudButtonStack
                    .transition(.move(edge: .leading))
                
                Spacer()
                
                hudButtonStack
                    .transition(.move(edge: .trailing))
            }
        }
    }
    
    var hudButtonStack: some View {
        
        VStack(alignment: .leading, spacing: 50) {
            
            ForEach(0..<3) { index in
                self.animatedButton
            }
        }
        .padding()
        
    }
    
    var animatedButton: some View {
        
        let randomImageName =  ["person.fill", "person.3.fill", "heart.fill", "ellipses.bubble.fill",
                                "paperplane.fill", "globe", "sparkles", "moon.stars.fill", "bolt.fill",
                                "doc.fill", "book.fill", "cloud.bolt.fill", "hurricane"]
            .randomElement()!
        
        return Circle()
            .frame(width: 75, height: 75)
            .foregroundColor(.randomExcludingBlackWhite)
            .opacity(0.85)
            .shadow(color: .black, radius: 5, x: 0, y: 10)
            .animation(self.animateHUDAppearance ? .spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.5) : .none)
            .overlay(Image(systemName: randomImageName).font(.largeTitle).foregroundColor(.white))
            .onAppear {
                /// Prevent re-animation on a new game state.
                self.animateHUDAppearance = false
            }
            .onDisappear {
                self.animateHUDAppearance = true
            }
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
