//
//  OctopusSceneController-Universal.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/24.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Seek a cleaner way to mix iOS- and macOS-specific code?

import SpriteKit
import GameplayKit

#if os(iOS) // CHECK: Include tvOS?

import UIKit

public typealias OSViewController = UIViewController

#elseif os(OSX)

import Cocoa

public typealias OSViewController = NSViewController

#endif

/// Coordinates between the SpriteKit view and game scenes. Signals the `OctopusGameController` to enter its initial state when the view is ready to present the first scene.
///
/// - Important: The view controller of your main SpriteKit view must be an `OctopusSceneController` or its subclass, for the OctopusKit to function.
public class OctopusSceneController: OSViewController, OctopusSceneDelegate {
    
    public fileprivate(set) var spriteKitView: SKView?
    
    public var currentScene: OctopusScene? {
        // CHECK: Should we return as SKScene?
        if let scene = self.spriteKitView?.scene as? OctopusScene {
            return scene
        }
        else {
            OctopusKit.logForDebug.add("Cannot access scene as an OctopusScene.")
            return nil
        }
    }
    
    /// This flags ensures that the `OctopusSceneController` evokes the `OctopusKit.shared.gameController` state machine's initial state only once.
    public fileprivate(set) var didEvokeGameControllerInitialState = false
    
    // MARK: - Life Cycle
    
    public override func viewDidLoad() {
        OctopusKit.logForFramework.add()
        super.viewDidLoad()
        
        guard let spriteKitView = self.view as? SKView else {
            fatalError("OctopusSceneController's view is not an SpriteKit SKView.")
        }
        
        // Configure the view...
        
        // NOTE: CHECK: Configuring the view here as it may screw up the dimensions, according to http://www.ymc.ch/en/ios-7-sprite-kit-setting-up-correct-scene-dimensions — CHECK: Still relevant?
        
        self.spriteKitView = spriteKitView
        spriteKitView.ignoresSiblingOrder = true // SpriteKit applies additional optimizations to improve rendering performance.
        
        //        spriteKitView.isMultipleTouchEnabled = ?
        //        audioEngine = OctopusAudioEngine()
        
        // ⚠️ NOTE: Create a blank placeholder scene to prevent a jarring white screen on launch, because that's what `SKView` seems to default to as of 2018-03,  until `OctopusGameController` and its initial state prepares the first scene prepare and presents its contents.
        
        presentScene(SKScene(size: spriteKitView.frame.size))
    }
    
    internal func enterInitialState() {
        OctopusKit.logForFramework.add()
        
        guard let engine = OctopusKit.shared else {
            fatalError("OctopusKit.shared not initialized")
        }
        
        // Even though the game controller's GKStateMachine should handle the correct transitions between states, this scene controller should only initiate the game controller's initial state only once, just to be extra safe, and also as a flag for other classes to refer to if needed.
        
        guard !didEvokeGameControllerInitialState else {
            OctopusKit.logForFramework.add("didEvokeGameControllerInitialState already set")
            return
        }
        
        engine.gameController.enterInitialState()
        self.didEvokeGameControllerInitialState = true
    }
    
    #if os(iOS)
    // MARK: iOS-Specific
    
    /// Specifies whether the scene controller prefers the status bar to be hidden or shown.
    ///
    /// This property allows other objects to dynamically override the associated read-only computed property of this scene controller.
    public var prefersStatusBarHiddenOverride: Bool = true {
        didSet { self.setNeedsStatusBarAppearanceUpdate() }
    }
    
    public override var prefersStatusBarHidden: Bool {
        return prefersStatusBarHiddenOverride
    }
    
    /// Specifies whether the system is allowed to hide the visual indicator for returning to the Home screen.
    ///
    /// This property allows other objects to dynamically override the associated read-only computed property of this scene controller.
    ///
    /// - NOTE: The system takes your preference into account, but setting this property to `true` is no guarantee that the indicator will be hidden.
    public var prefersHomeIndicatorAutoHiddenOverride: Bool = true {
        didSet { self.setNeedsUpdateOfHomeIndicatorAutoHidden() }
    }
    
    #if swift(>=4.2)
    // TODO: Remove this conditional compilation flag and incorporate changes into main code after Swift 4.2 launches.
    public override var prefersHomeIndicatorAutoHidden: Bool {
        return prefersHomeIndicatorAutoHiddenOverride
    }
    #else
    public override func prefersHomeIndicatorAutoHidden() -> Bool {
        return prefersHomeIndicatorAutoHiddenOverride
    }
    #endif
    
    /// Specifies whether whether the scene controller's contents should auto rotate.
    ///
    /// This property allows other objects to dynamically override the associated read-only computed property of this scene controller.
    public var shouldAutorotateOverride: Bool = false
    
    public override var shouldAutorotate: Bool {
        return shouldAutorotateOverride
    }
    
    /// Contains a dictionary of the interface orientations (rotations) that the scene controller supports.
    ///
    /// This property allows other objects to dynamically override the read-only `supportedInterfaceOrientations` computed property of this scene controller.
    public var supportedInterfaceOrientationsOverride: [UIUserInterfaceIdiom : UIInterfaceOrientationMask] = [
        .phone: .allButUpsideDown
    ]
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // If the `interfaceOrientations` dictionary does not contain a list of orientations for the current `userInterfaceIdiom`, return `all`.
        return self.supportedInterfaceOrientationsOverride[UIDevice.current.userInterfaceIdiom] ?? .all
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        OctopusKit.logForFramework.add()
        super.viewWillAppear(animated)
        
        // NOTE: Do not call `enterInitialState()` from `viewWillAppear(_:)` as the OctopusScene's `prepareContents()` method may need access to the SKView's `safeAreaInsets`, which is [apparently] only set in `viewWillLayoutSubviews()` and may be necessary for positioning elements correctly on an iPhone X and other devices.
    }
    
    public override func viewWillLayoutSubviews() {
        // CREDIT: http://www.ymc.ch/en/ios-7-sprite-kit-setting-up-correct-scene-dimensions
        OctopusKit.logForFramework.add()
        super.viewWillLayoutSubviews()
        
        // Configure the view.
        
        spriteKitView?.ignoresSiblingOrder = true // Sprite Kit applies additional optimizations to improve rendering performance
        
        // NOTE: As the OctopusScene's `prepareContents()` method may need access to the SKView's `safeAreaInsets`, which is [apparently] only set in `viewWillLayoutSubviews()` and may be necessary for positioning elements correctly on an iPhone X and other devices, we should call `enterInitialState()` from here and not later from `viewWillAppear(_:)`.
        // NOTE: Better yet, `enterInitialState()` from `OctopusAppDelegate.applicationDidBecomeActive(_:)`! :)
        // CHECK: Compare launch performance between calling `enterInitialState()` from `OctopusAppDelegate.applicationDidBecomeActive(_:)` versus `OctopusSceneController.viewWillLayoutSubviews()`
        // enterInitialState()
    }
    
    public override func didReceiveMemoryWarning() {
        // Release any cached data, images, etc that aren't in use.
        OctopusKit.logForResources.add() // CHECK: Should the log be written to before freeing up some memory?
        super.didReceiveMemoryWarning()
        OctopusKit.clearAllCaches()
    }
    
    #endif
    
    #if os(OSX)
    // MARK: macOS-specific
    
    public override func viewWillAppear() {
        OctopusKit.logForFramework.add()
        super.viewWillAppear()
        
        // NOTE: Do not call `enterInitialState()` from `viewWillAppear(_:)` as the OctopusScene's `prepareContents()` method may need access to the SKView's `safeAreaInsets`, which is [apparently] only set in `viewWillLayoutSubviews()` and may be necessary for positioning elements correctly on an iPhone X and other devices.
    }
    
    public override func viewWillLayout() {
        // CREDIT: http://www.ymc.ch/en/ios-7-sprite-kit-setting-up-correct-scene-dimensions
        OctopusKit.logForFramework.add()
        super.viewWillLayout()
        
        // Configure the view.
        
        spriteKitView?.ignoresSiblingOrder = true // Sprite Kit applies additional optimizations to improve rendering performance
        
        // NOTE: As the OctopusScene's `prepareContents()` method may need access to the SKView's `safeAreaInsets`, which is [apparently] only set in `viewWillLayoutSubviews()` and may be necessary for positioning elements correctly on an iPhone X and other devices, we should call `enterInitialState()` from here and not later from `viewWillAppear(_:)`.
        // NOTE: Better yet, `enterInitialState()` from `OctopusAppDelegate.applicationDidBecomeActive(_:)`! :)
        // CHECK: Compare launch performance between calling `enterInitialState()` from `OctopusAppDelegate.applicationDidBecomeActive(_:)` versus `OctopusSceneController.viewWillLayoutSubviews()`
        // enterInitialState()
    }
    
    #endif
    
    // MARK: - Scene Presentation
    
    /// Loads the `.sks` file as an OctopusScene.
    /// - Requires: In the Scene Editor, the scene must have its "Custom Class" set to `OctopusScene` or a subclass of `OctopusScene`.
    public func loadScene(fileNamed fileName: String) -> OctopusScene? {
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
            OctopusKit.logForErrors.add("Cannot load \"\(fileName)\" as OctopusScene")
            return nil
        }
        
        // Copy gameplay related content over to the scene
        
        spriteKitScene.addEntities(gameplayKitScene.entities)
        spriteKitScene.renameUnnamedEntitiesToNodeNames() // TODO: FIX: ⚠️ Does not work when loading an `.sks` because Editor-created entities are not `OctopusEntity`
        spriteKitScene.graphs = gameplayKitScene.graphs
        spriteKitScene.octopusSceneDelegate = self
        
        return spriteKitScene
    }
    
    public func createScene(ofClass sceneClass: OctopusScene.Type) -> OctopusScene?
    {
        OctopusKit.logForFramework.add("\(sceneClass)")
        
        guard let spriteKitView = self.view as? SKView else {
            fatalError("\(self) does not have an SpriteKit SKView.") // TODO: Add internationalization.
        }
        
        let newScene = sceneClass.init(size: spriteKitView.frame.size)
        newScene.octopusSceneDelegate = self
        
        return newScene
    }
    
    public func presentScene(
        _ scene: SKScene,
        withTransition transition: SKTransition? = nil)
    {
        OctopusKit.logForFramework.add("\(String(optional: spriteKitView?.scene)) → [\(transition == nil ? "no transition" : String(optional: transition))] → \(scene)")
        
        guard let spriteKitView = self.view as? SKView else {
            fatalError("\(self) does not have an SpriteKit SKView.") // TODO: Add internationalization.
        }
        
        if let octopusScene = scene as? OctopusScene {
            octopusScene.octopusSceneDelegate = self
            octopusScene.willMove(to: spriteKitView)
        }
        
        if let transition = transition {
            spriteKitView.presentScene(scene, transition: transition)
        }
        else {
            spriteKitView.presentScene(scene)
        }
    }
    
    @discardableResult public func createAndPresentScene(
        ofClass sceneClass: OctopusScene.Type,
        withTransition transition: SKTransition? = nil)
        -> OctopusScene?
    {
        if let scene = createScene(ofClass: sceneClass) {
            presentScene(scene, withTransition: transition)
            return scene
        }
        else {
            return nil
        }
    }
    
    @discardableResult public func loadAndPresentScene(
        fileNamed fileName: String,
        withTransition transition: SKTransition? = nil)
        -> OctopusScene?
    {
        if let scene = loadScene(fileNamed: fileName) {
            presentScene(scene, withTransition: transition)
            return scene
        }
        else {
            return nil
        }
    }
    
    // MARK: - OctopusSceneDelegate
    
    public func octopusSceneDidFinish(_ scene: OctopusScene) {
        // Let the current `OctopusGameState` handle this.
        
        if let currentState = OctopusKit.shared?.gameController.currentState as? OctopusGameState {
            currentState.octopusSceneDidFinish(scene)
        }
    }
    
    @discardableResult public func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        // Let the current `OctopusGameState` handle this.
        
        if let currentState = OctopusKit.shared?.gameController.currentState as? OctopusGameState {
            return currentState.octopusSceneDidChooseNextGameState(scene)
        }
        else {
            return false
        }
    }
    
    @discardableResult public func octopusSceneDidChoosePreviousGameState(_ scene: OctopusScene) -> Bool {
        // Let the current `OctopusGameState` handle this.
        
        if let currentState = OctopusKit.shared?.gameController.currentState as? OctopusGameState {
            return currentState.octopusSceneDidChoosePreviousGameState(scene)
        }
        else {
            return false
        }
    }
    
    /// May be overriden in subclass to provide transition validation.
    @discardableResult public func octopusScene(_ scene: OctopusScene, didRequestGameStateClass stateClass: OctopusGameState.Type) -> Bool {
        // Let the current `OctopusGameState` handle this.
        
        if let currentState = OctopusKit.shared?.gameController.currentState as? OctopusGameState {
            return currentState.octopusScene(scene, didRequestGameStateClass: stateClass)
        }
        else {
            return OctopusKit.shared?.gameController.enter(stateClass) ?? false
        }
    }
    
    /// Override in subclass to implement more granular control over transitions between specific types of scenes.
    public func octopusScene(
        _ outgoingScene: OctopusScene,
        didRequestTransitionTo nextSceneFileName: String,
        withTransition transition: SKTransition? = nil)
    {
        OctopusKit.logForFramework.add("nextSceneFileName = \(nextSceneFileName)")
        
        guard let spriteKitView = self.view as? SKView else {
            fatalError("OctopusSceneController's view is not an SpriteKit SKView.")
        }
        
        guard let nextScene = loadScene(fileNamed: nextSceneFileName) else { return }
        
        nextScene.willMove(to: spriteKitView)
        
        if let transition = transition {
            spriteKitView.presentScene(nextScene, transition: transition)
        }
        else {
            spriteKitView.presentScene(nextScene)
        }
        
        outgoingScene.isPaused = false // CHECK: Necessary?
    }
    
    /// Override in subclass to implement more granular control over transitions between specific types of scenes.
    public func octopusScene(
        _ outgoingScene: OctopusScene,
        didRequestTransitionTo nextSceneClass: OctopusScene.Type,
        withTransition transition: SKTransition? = nil)
    {
        OctopusKit.logForFramework.add("nextSceneClass = \(nextSceneClass)")
        self.createAndPresentScene(ofClass: nextSceneClass)
        outgoingScene.isPaused = false // CHECK: Necessary?
    }
    
}


