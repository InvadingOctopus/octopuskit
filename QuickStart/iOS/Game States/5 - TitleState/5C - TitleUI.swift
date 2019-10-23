//
//  TitleUI.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/20.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 5C: The user interface overlay for the title screen of the QuickStart project.
//
//  This view displays a button which signals the game coordinator to enter the next game state, along with a few other controls to demonstrate SwiftUI.
//
//  ❕ SThis file is more of a demo than a tutorial; it may seem moderately complex because of the custom views and animations. Once you understand how the "Cycle State" button works, you may delete this file and replace it with your own UI.

import SwiftUI
import OctopusKit

struct TitleUI: View {
    
    @EnvironmentObject var gameCoordinator: MyGameCoordinator
    
    var suppressAppearanceAnimation = false
    
    @State var didAppear = false
    @State var showMoreUI = false
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            moreUI
            
            Spacer()
            
            if didAppear || suppressAppearanceAnimation {
        
                mainButtons
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom))
                    .animation(.spring(dampingFraction: 0.5))
            }
                        
        }
        .onAppear {
            self.didAppear = true
        }
    }
    
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
    
    func nextGameState() {
        if let currentScene = gameCoordinator.currentScene {
            OctopusKit.logForDebug.add("Next state button tapped!")
            currentScene.octopusSceneDelegate?.octopusSceneDidChooseNextGameState(currentScene)
        }
    }
    
    func toggleMoreUI() {
        withAnimation(.spring()) {
            showMoreUI.toggle()
        }
    }
    
    //
    
    var moreUI: some View {
        
        HStack(alignment: .center) {
            
            if showMoreUI {
            
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
                AnimatedButton(place: index)
            }
        }
    }
    
    struct AnimatedButton: View {
        let place: Int
        
        @State private var rotation = Angle(degrees: 90)
        
        var randomImageName = ["person.fill", "person.3.fill", "heart.fill", "ellipses.bubble.fill",
                               "paperplane.fill", "globe", "sparkles", "moon.stars.fill", "bolt.fill",
                               "doc.fill", "book.fill", "cloud.bolt.fill", "hurricane"
            ].randomElement()!
        
        var body: some View {
            
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 75, height: 75)
                .foregroundColor(.randomExcludingBlackWhite)
                .opacity(0.85)
                .shadow(color: .black, radius: 10, x: 0, y: 10)
                .rotationEffect(rotation, anchor: .center)
                .animation(Animation
                    .spring(dampingFraction: 0.3)
                    .delay(0.1 * Double(place)))
                .overlay(Image(systemName: randomImageName).font(.largeTitle).foregroundColor(.white))
                .onAppear {
                    withAnimation(.easeOut) {
                        self.rotation = Angle(degrees: 0)
                    }
                }
                .padding(.horizontal)
        }
    }
    
}

//

struct RotationTransitionModifier: ViewModifier {
    let active: Bool
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: active ? 90 : 0))
    }
}

extension AnyTransition {
    static let rotation = AnyTransition.modifier(
        active: RotationTransitionModifier(active: true),
        identity: RotationTransitionModifier(active: false))
}

//

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
