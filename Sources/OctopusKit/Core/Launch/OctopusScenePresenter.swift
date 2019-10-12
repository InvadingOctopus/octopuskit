//
//  OctopusScenePresenter.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/12.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

public protocol OctopusScenePresenter {
    
    var spriteKitView: SKView? { get }
    var currentScene: OctopusScene? { get }
    
    func loadScene(fileNamed fileName: String) -> OctopusScene?
    
    func createScene(ofClass sceneClass: OctopusScene.Type) -> OctopusScene?
    
    func presentScene(_ incomingScene: OctopusScene, withTransition transitionOverride: SKTransition?)
    
    @discardableResult func createAndPresentScene(ofClass sceneClass: OctopusScene.Type, withTransition transition: SKTransition?) -> OctopusScene?
    
    @discardableResult func loadAndPresentScene(fileNamed fileName: String, withTransition transition: SKTransition?) -> OctopusScene?
}

public extension OctopusScenePresenter {
    
    // MARK: - OctopusScenePresenter
    
    /// Loads an `.sks` file as an OctopusScene.
    /// - Requires: In the Scene Editor, the scene must have its "Custom Class" set to `OctopusScene` or a subclass of `OctopusScene`.
    func loadScene(fileNamed fileName: String) -> OctopusScene? {
        // TODO: Error handling
        
        OctopusKit.logForResources.add("fileName = \"\(fileName)\"")
        
        // Load the specified scene as a GKScene. This provides gameplay related content including entities and graphs.
        
        guard let gameplayKitScene = GKScene(fileNamed: fileName) else {
            OctopusKit.logForErrors.add("Cannot load \"\(fileName)\" as GKScene")
            return nil
        }
        
        // Get the OctopusScene/SKScene from the loaded GKScene
        guard let spriteKitScene = gameplayKitScene.rootNode as? OctopusScene else {
            // TODO: Graceful failover to `SKScene(fileNamed:)`
            OctopusKit.logForErrors.add("Cannot load \"\(fileName)\" as an OctopusScene")
            return nil
        }
        
        // Copy gameplay related content over to the scene
        
        spriteKitScene.addEntities(gameplayKitScene.entities)
        spriteKitScene.renameUnnamedEntitiesToNodeNames() // TODO: FIX: ⚠️ Does not work when loading an `.sks` because Editor-created entities are not `OctopusEntity`
        spriteKitScene.graphs = gameplayKitScene.graphs
        spriteKitScene.octopusSceneDelegate = (self as? OctopusSceneDelegate)
        
        return spriteKitScene
    }
    
    func createScene(ofClass sceneClass: OctopusScene.Type) -> OctopusScene?
    {
        OctopusKit.logForFramework.add("\(sceneClass)")
        
        guard let spriteKitView = self.spriteKitView else {
            fatalError("\(self) does not have a spriteKitView?") // TODO: Add internationalization.
        }
        
        let newScene = sceneClass.init(size: spriteKitView.frame.size)
        newScene.octopusSceneDelegate = (self as? OctopusSceneDelegate)
        
        return newScene
    }
    
    /// - Parameter incomingScene: The scene to present.
    /// - Parameter transitionOverride: The transition animation to display between scenes.
    ///
    ///     If `nil` or omitted, the transition is provided by the `transition(for:)` method of the current scene, if any.
    func presentScene(_ incomingScene: OctopusScene,
                      withTransition transitionOverride: SKTransition? = nil)
    {
        OctopusKit.logForFramework.add("\(String(optional: self.spriteKitView?.scene)) → [\(transitionOverride == nil ? "no transition override" : String(optional: transitionOverride))] → \(incomingScene)")
        
        guard let spriteKitView = self.spriteKitView else {
            fatalError("\(self) does not have an spriteKitView?") // TODO: Add internationalization.
        }
        
        // Notify the incoming scene that it is about to be presented.
        // CHECK: Casting `as? OctopusScene` not necessary anymore?
        
        incomingScene.octopusSceneDelegate = (self as? OctopusSceneDelegate)
        incomingScene.gameController = (self as? OctopusGameController)
        incomingScene.willMove(to: spriteKitView)
        
        // If an overriding transition has not been specified, let the current scene decide the visual effect for the transition to the next scene.
        
        // ℹ️ DESIGN: It makes more sense for the outgoing state/scene to decide the transition effect, which may depend on their variables, rather than the incoming scene.
        
        let transition = transitionOverride ?? self.currentScene?.transition(for: type(of: incomingScene))
        
        if let transition = transition {
            spriteKitView.presentScene(incomingScene, transition: transition)
        } else {
            spriteKitView.presentScene(incomingScene)
        }
    }
    
    /// - Parameter sceneClass: The scene class to create an instance of.
    /// - Parameter transition: The transition animation to display between scenes.
    ///
    ///     If `nil` or omitted, the transition is provided by the `transition(for:)` method of the current scene, if any.
    @discardableResult func createAndPresentScene(
        ofClass sceneClass: OctopusScene.Type,
        withTransition transition: SKTransition? = nil)
        -> OctopusScene?
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
        -> OctopusScene?
    {
        if  let scene = loadScene(fileNamed: fileName) {
            presentScene(scene, withTransition: transition)
            return scene
        } else {
            return nil
        }
    }
    
}
