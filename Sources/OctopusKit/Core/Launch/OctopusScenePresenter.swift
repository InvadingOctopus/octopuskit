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
    
    func loadScene(fileNamed fileName: String) -> OctopusScene?
    
    func createScene(ofClass sceneClass: OctopusScene.Type) -> OctopusScene?
    
    func presentScene(_ incomingScene: OctopusScene, withTransition transitionOverride: SKTransition?)
    
    @discardableResult func createAndPresentScene(ofClass sceneClass: OctopusScene.Type, withTransition transition: SKTransition?) -> OctopusScene?
    
    @discardableResult func loadAndPresentScene(fileNamed fileName: String, withTransition transition: SKTransition?) -> OctopusScene?
}

// MARK: - Default Implementation

public extension OctopusScenePresenter {
    
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
