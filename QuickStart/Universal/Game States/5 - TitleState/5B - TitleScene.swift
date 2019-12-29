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

final class TitleScene: OKScene {
    
    // MARK: - Life Cycle
    
    // MARK: 🔶 STEP 5B.1
    override func sceneDidLoad() {
        
        // Set the name of this scene at the earliest override-able point, for logging purposes.
        
        self.name = "QuickStart Title Scene"
        super.sceneDidLoad()
    }
    
    // MARK: 🔶 STEP 6B.2
    override func createComponentSystems() -> [GKComponent.Type] {
        
        // This method is called by the OKScene superclass, after the scene has been presented in a view, to create a list of systems for each component type that must be updated in every frame of this scene.
        //
        // ❗️ The order of components is important, as the functionality of some components depends on the output of other components.
        //
        // See the code and documentation for each component to check its requirements.
        
        [
            // Components that process player input, provided by OctopusKit.
            
            OSMouseOrTouchEventComponent.self,
            PointerEventComponent.self, // This component translates touch or mouse input into an OS-agnostic "pointer" format, which is used by other input-processing components that work on iOS as well as macOS.
            
            // Custom components which are specific to this QuickStart project.
            
            GlobalDataComponent.self,
            TitleEffectsComponent.self
        ]
    }
    
    // MARK: 🔶 STEP 6B.3
    override func createContents() {
        
        // This method is called by the OKScene superclass, after the scene has been presented in a view, to let each subclass (the scenes specific to your game) prepare their contents.
        //
        // The most common tasks for every scene are to prepare the order of the component systems which the scene will update every frame, and to add entities to the scene.
        //
        // Calling super for this method is not necessary; it only adds a log entry.
        
        super.createContents()

        // Create the entities to present in this scene.
        
        // Set the permanent visual properties of the scene itself.
        
        self.anchorPoint = CGPoint.half
        self.backgroundColor = SKColor(red: 0.2, green: 0.1, blue: 0.5, alpha: 1.0)
            
        // Add components to the scene entity.
        
        self.entity?.addComponent(TitleEffectsComponent())
        
        // Create a label to display the game's title.
        
        // First we create a SpriteKit node.
        
        let title = SKLabelNode(text: "TOTALLY RAD GAME™",
                                font: OKFont(name: "AvenirNextCondensed-Bold",
                                                  size: 40,
                                                  color: .white))
        
        title.setAlignment(horizontal: .center, vertical: .top)
        
        title.position = CGPoint(x: 0,
                                 y: self.frame.size.halved.height - title.frame.size.halved.height)
        
        title.insetPositionBySafeArea(at: .top, forView: self.view)
        
        // Create a SKEffectNode so we can add a cool shader effect to the title to make it funky, otherwise we should just have used a SwiftUI text view. :)
        
        let effectNode = SKEffectNode(children: [title])
        effectNode.alpha = 0.8
        effectNode.blendMode = .screen
        
        let shader = SKShader(source: """
            void main() {
                vec2 uv = v_tex_coord;
                float xTimeFactor = 1.0;
                float yTimeFactor = 1.0;

                uv.x += (sin((uv.y + (u_time * xTimeFactor)) * 15.0) * 0.0029) +
                (sin((uv.y + (u_time * 0.1)) * 15.0) * 0.002);

                uv.y += (cos((uv.y + (u_time * yTimeFactor)) * 45.0) * 0.0019) +
                (cos((uv.y + (u_time * 0.1)) * 10.0) * 0.002);

                gl_FragColor = texture2D(u_texture, uv); }
            """)
        
        // Then we create an entity with the effect node (which contains the label node.)
        
        self.addEntity(OKEntity(name: "TitleEntity", components: [
            SpriteKitComponent(node: effectNode),
            ShaderComponent(shader: shader)
            ]))
        
        // Add the global game coordinator entity to this scene so that global components will be included in the update cycle, and updated in the order specified by this scene's `componentSystems` array.
        
        if  let gameCoordinatorEntity = OctopusKit.shared?.gameCoordinator.entity {
            self.addEntity(gameCoordinatorEntity)
        }
    }
    
    // MARK: - Frame Update
    
    // MARK: 🔶 STEP 5B.4
    override func shouldUpdateSystems(deltaTime: TimeInterval) -> Bool {
        
        // This method is not necessary but provided here for explanation:
        //
        // OctopusKit handles all the boilerplate per-frame logic, like timer calculations, frame counts, entity management and pause/unpause behavior.
        //
        // The `OKScene.update(_:)` method, which is executed at the beginning of every frame by SpriteKit, calls this `shouldUpdateSystems(deltaTime:)` before updating the components of all entities.
        //
        // This saves you from writing a lot of identical code for every scene, while still offering a customization point for your scenes that have custom pause/unpause behavior or need to perform other per-frame logic.
        //
        // By default this method just checks all the paused flags, and returns true if none are true. That's what we're going to do here too. :)
        //
        // 💡 For an overview of the SpriteKit frame cycle, see Apple's documentation:
        // https://developer.apple.com/documentation/spritekit/skscene/responding_to_frame-cycle_events
        
        return (!isPaused && !isPausedBySystem && !isPausedByPlayer && !isPausedBySubscene)
    }

    // MARK: - State & Scene Transitions
    
    // MARK: 🔶 STEP 5B.5
    override func transition(for nextSceneClass: OKScene.Type) -> SKTransition? {
        
        // This method is called by the game coordinator (via the OKScenePresenter protocol) to ask the current scene for a transition animation between the outgoing scene and the next scene.
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
        
        // Next, provide the OKScenePresenter with an animation to apply between the contents of this scene and the upcoming scene.
        
        let transition = SKTransition.doorsOpenVertical(withDuration: 2.0)
        
        transition.pausesOutgoingScene = false
        transition.pausesIncomingScene = false
        
        return transition
    }
    
}

// NEXT: See TitleUI (STEP 5C) and PlayState (STEP 6)
