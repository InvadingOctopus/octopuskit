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
    @State private var showMoreUI = showMoreUIGlobal {
        didSet {
            TitleUI.showMoreUIGlobal = showMoreUI
        }
    }
    
    /// Since TitleUI is also used in PlayUI, we copy the showMoreUI setting to a static variable which persists across multiple game states, otherwise it would get reset when the game state changes.
    static var showMoreUIGlobal = false
        
    var body: some View {
        
        VStack {
            
            Spacer()
            
            moreUI
            
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
            // Set a flag to start the initial animation.
            self.didAppear = true
        }
        
    }
    
    // MARK: - Main Buttons
    // To cycle the game state and display demo UI.
    //
    // Note that the subviews are all instance variables instead of standalone struct types, as they are only used inside TitleUI.
    
    var mainButtons: some View {
        
        VStack {
            
            toggleMoreUIButton
            
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
    
    var toggleMoreUIButton: some View {
        Button(action: toggleMoreUI) {
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
    
    func toggleMoreUI() {
        showMoreUI.toggle()
        TitleUI.showMoreUIGlobal = showMoreUI
    }
    
    // MARK: - Superficial UI
    // To demonstrate animation and HUD overlays.
    
    var moreUI: some View {
        
        HStack(alignment: .center) {
            
            if showMoreUI || TitleUI.showMoreUIGlobal {
                
                moreUIButtonStack
                    .transition(.move(edge: .leading))
                
                Spacer()
                
                moreUIButtonStack
                    .transition(.move(edge: .trailing))
            }
        }
    }
    
    var moreUIButtonStack: some View {
        
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
            .animation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.5))
            .overlay(Image(systemName: randomImageName).font(.largeTitle).foregroundColor(.white))
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
