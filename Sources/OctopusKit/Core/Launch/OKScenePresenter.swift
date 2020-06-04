//
//  OKScenePresenter.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/12.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

public typealias OctopusScenePresenter = OKScenePresenter

public protocol OKScenePresenter: class {

    // DESIGN: This functionality is presented as a protocol so that it may be swapped between the view controller, game coordinator or game state, depending on the needs of the underlying system framework (such as SwiftUI or UIKit.)

    var spriteKitView:    SKView?      { get }
    var currentScene:     OKScene?     { get set }
    var currentGameState: OKGameState? { get }
    
    func loadScene(fileNamed fileName: String) -> OKScene?
    
    func createScene(ofClass sceneClass: OKScene.Type) -> OKScene?
    
    func presentScene(_ incomingScene: OKScene,
                      withTransition transitionOverride: SKTransition?)
    
    @discardableResult func createAndPresentScene(ofClass sceneClass: OKScene.Type,
                                                  withTransition transition: SKTransition?) -> OKScene?
    
    @discardableResult func loadAndPresentScene(fileNamed fileName: String,
                                                withTransition transition: SKTransition?) -> OKScene?
}

// MARK: - Default Implementation

public extension OKScenePresenter {
        
    /// Creates and returns an instance of the specified `OKScene` subclass.
    func createScene(ofClass sceneClass: OKScene.Type) -> OKScene?
    {
        OctopusKit.logForFramework("\(sceneClass)")
        
        guard let spriteKitView = self.spriteKitView else {
            OctopusKit.logForErrors("\(self) does not have a spriteKitView — Creating scenes programmatically requires screen dimensions. 💡 Use loadScene(fileNamed:) to load a .sks made in the Xcode editor.") // TODO: Add internationalization.
            return nil
        }
        
        let newScene = sceneClass.init(size: spriteKitView.frame.size)
        
        // CHECK: Should the delegate be set here or only on presentation?
        // newScene.octopusSceneDelegate = self.currentGameState
        
        return newScene
    }
    
    /// Loads an `.sks` file as an OKScene.
    /// - Requires: In the Scene Editor, the scene must have its "Custom Class" set to `OKScene` or a subclass of `OKScene`.
    func loadScene(fileNamed fileName: String) -> OKScene? {
        // TODO: Error handling
        
        OctopusKit.logForResources("fileName = \"\(fileName)\"")
        
        // Load the specified scene as a GKScene. This provides gameplay related content including entities and graphs.
        
        guard let gameplayKitScene = GKScene(fileNamed: fileName) else {
            OctopusKit.logForErrors("Cannot load \"\(fileName)\" as GKScene")
            return nil
        }
        
        // Get the OKScene/SKScene from the loaded GKScene
        guard let spriteKitScene = gameplayKitScene.rootNode as? OKScene else {
            // TODO: Graceful failover to `SKScene(fileNamed:)`
            OctopusKit.logForErrors("Cannot load \"\(fileName)\" as an OKScene")
            return nil
        }
        
        // Copy gameplay related content over to the scene
        
        spriteKitScene.addEntities(gameplayKitScene.entities)
        spriteKitScene.renameUnnamedEntitiesToNodeNames() // TODO: FIX: ⚠️ Does not work when loading an `.sks` because Editor-created entities are not `OKEntity`
        spriteKitScene.graphs = gameplayKitScene.graphs
        
        // CHECK: Should the delegate be set here or only on presentation?
        // spriteKitScene.octopusSceneDelegate = self.currentGameState
        
        return spriteKitScene
    }
    
    /// - Parameter incomingScene: The scene to present.
    /// - Parameter transitionOverride: The transition animation to display between scenes.
    ///
    ///     If `nil` or omitted, the transition is provided by the `transition(for:)` method of the current scene, if any.
    func presentScene(_ incomingScene: OKScene,
                      withTransition transitionOverride: SKTransition? = nil)
    {
        // ℹ️ DESIGN: It makes more sense for the outgoing state/scene to decide the transition effect, which may depend on their variables, rather than the incoming scene.
        
        let transition = transitionOverride ?? self.currentScene?.transition(for: type(of: incomingScene))
        
        OctopusKit.logForFramework("\(self.currentScene) → [\(transition)] → \(incomingScene)")
        
        // If the specified scene is already the current scene (as may be the case for scenes that handle multiple states, such as playing and paused) just set its delegate to the current state and return.

        incomingScene.octopusSceneDelegate = self.currentGameState

        guard incomingScene !== self.currentScene else {
            OctopusKit.logForFramework("incomingScene is already currentScene — Resetting delegate but skipping presentation.")
            return
        }
        
        // Notify the incoming scene that it is about to be presented.
        
        guard let spriteKitView = self.spriteKitView else {
            fatalError("\(self) does not have an spriteKitView?") // TODO: Add internationalization.
        }

        incomingScene.willMove(to: spriteKitView)
        
        // If an overriding transition has not been specified, let the current scene decide the visual effect for the transition to the next scene.
            
        if  let transition = transition {
            spriteKitView.presentScene(incomingScene, transition: transition)
        } else {
            spriteKitView.presentScene(incomingScene)
        }
        
        // ⚠️ BUG? NOTE: Set `currentScene` to `incomingScene`, because the `spriteKitView.scene` will still be the previous (outgoing) scene at this point for some reason.
                
        if  spriteKitView.scene is OKScene {
            self.currentScene = incomingScene
        } else {
            OctopusKit.logForErrors("Cannot cast spriteKitView.scene as OKScene: \(spriteKitView.scene)")
        }

        // Let the new scene determine UI focus for the Apple TV Remote.
        // CHECK: Necessary?
        
        #if os(tvOS)
        spriteKitView.setNeedsFocusUpdate()
        // CHECK: Also call `spriteKitView.updateFocusIfNeeded()`?
        #endif
        
    }
    
    /// - Parameter sceneClass: The scene class to create an instance of.
    /// - Parameter transition: The transition animation to display between scenes.
    ///
    ///     If `nil` or omitted, the transition is provided by the `transition(for:)` method of the current scene, if any.
    @discardableResult func createAndPresentScene(
        ofClass sceneClass: OKScene.Type,
        withTransition transition: SKTransition? = nil)
        -> OKScene?
    {
        if  let scene = createScene(ofClass: sceneClass) {
            presentScene(scene, withTransition: transition)
            return scene
        } else {
            return nil
        }
    }
    
    /// - Parameter fileName: The filename of the scene to load.
    /// - Parameter transition: The transition animation to display between scenes.
    ///
    ///     If `nil` or omitted, the transition is provided by the `transition(for:)` method of the current scene, if any.
    @discardableResult func loadAndPresentScene(
        fileNamed fileName: String,
        withTransition transition: SKTransition? = nil)
        -> OKScene?
    {
        if  let scene = loadScene(fileNamed: fileName) {
            presentScene(scene, withTransition: transition)
            return scene
        } else {
            return nil
        }
    }
    
}
