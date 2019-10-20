//
//  TitleScene.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 5B: The title screen for the QuickStart project.
//
//  The user interface is described in TitleUI.swift (see explanation in STEP 5B.2)

import SpriteKit
import GameplayKit
import OctopusKit

final class TitleScene: OctopusScene {
    
    // MARK: - Life Cycle
    
    // MARK: 🔶 STEP 5B.1
    override func sceneDidLoad() {
        
        // Set the name of this scene at the earliest override-able point, for logging purposes.
        
        self.name = "QuickStart Title Scene"
        super.sceneDidLoad()
    }
    
    // MARK: 🔶 STEP 5B.2
    override func prepareContents() {
        
        // This method is called by the OctopusScene superclass, after the scene has been presented in a view, to let each subclass (the scenes specific to your game) prepare their contents.
        //
        // The most common tasks for every scene are to prepare the order of the component systems which the scene will update every frame, and to add entities to the scene.
        //
        // For clarity, this subclass divides those steps into two functions: createComponentSystems() and createEntities()
        //
        // Calling super for this method is not necessary; it only adds a log entry.
        
        super.prepareContents()
        
        createComponentSystems()
        createEntities()
    }
    
    // MARK: 🔶 STEP 5B.3
    fileprivate func createComponentSystems() {
        
        // Create a list of systems for each component type that must be updated in every frame of this scene.
        //
        // ❗️ The order of components is important. The functionality of some components depends on the output of other components.
        //
        // See the code and documentation for each component to check its requirements.
        
        componentSystems.createSystems(forClasses: [
            
            // Components that process player input, provided by OctopusKit.
            
            TouchEventComponent.self,
            
            // Custom components which are specific to this QuickStart project.
            
            GlobalDataComponent.self,
            ])
    }
    
    // MARK: 🔶 STEP 5B.4
    fileprivate func createEntities() {
        
        // Create the entities to present in this scene.
        
        // Set the permanent visual properties of the scene itself.
        
        self.anchorPoint = CGPoint.half
        self.backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
            
        // Add components to the scene entity.
        
        self.entity?.addComponent(sharedTouchEventComponent)
        
        // Create a label to display the game's title.
        
        // First we create a SpriteKit node.
        
        let title = SKLabelNode(text: "EPIC NEW NAME™",
                                font: OctopusFont(name: "AvenirNextCondensed-Bold",
                                                  size: 25,
                                                  color: .white))
        
        title.setAlignment(horizontal: .center, vertical: .top)
        
        title.position = CGPoint(x: 0,
                                 y: self.frame.size.halved.height - title.frame.size.halved.height)
        
        title.insetPositionBySafeArea(at: .top, forView: self.view)
        
        // Then we create an entity with that node.
        
        self.addEntity(OctopusEntity(name: "TitleEntity", components: [
            SpriteKitComponent(node: title)
            ]))
        
        // Add the global game coordinator entity to this scene so that global components will be included in the update cycle.
        
        if let gameCoordinatorEntity = OctopusKit.shared?.gameCoordinator.entity {
            self.addEntity(gameCoordinatorEntity)
        }
    }
    
    // MARK: - Frame Update
    
    // MARK: 🔶 STEP 5B.5
    override func update(_ currentTime: TimeInterval) {
        
        // Update component systems every frame after checking the paused flags.
        //
        // ❗️ NOTE: Calling super.update(currentTime) is essential before any other code in the subclass' method.
        //
        // OctopusKit defers component updates to the OctopusScene subclass, because each specific scene may need to handle pausing, unpausing and other tasks differently. See PlayScene for an example.

        super.update(currentTime)
        guard !isPaused, !isPausedBySystem, !isPausedByPlayer, !isPausedBySubscene else { return }
        
        updateSystems(in: componentSystems, deltaTime: updateTimeDelta)
    }
    
    // MARK: - State & Scene Transitions
    
    // MARK: 🔶 STEP 5B.6
    override func transition(for nextSceneClass: OctopusScene.Type) -> SKTransition? {
        
        // This method is called by the game coordinator (via the OctopusScenePresenter protocol) to ask the current scene for a transition animation between the outgoing scene and the next scene.
        //
        // Here we display transition effects if the next scene is the PlayScene.
        
        guard nextSceneClass is PlayScene.Type else { return nil }
        
        // First, apply some effects to the current scene.
        
        let colorFill = SKSpriteNode(color: .black, size: self.frame.size)
        colorFill.alpha = 0
        colorFill.zPosition = 1000
        self.addChild(colorFill)
        
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 1.0).withTimingMode(.easeIn)
        colorFill.run(fadeIn)
        
        // Next, provide the OctopusScenePresenter with an animation to apply between the contents of this scene and the upcoming scene.
        
        let transition = SKTransition.doorsOpenVertical(withDuration: 2.0)
        
        transition.pausesOutgoingScene = false
        transition.pausesIncomingScene = false
        
        return transition
    }
    
}

// NEXT: See TitleUI (STEP 5C) and PlayState (STEP 6)
