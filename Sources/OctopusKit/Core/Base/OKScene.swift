//
//  OKScene.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-10-15
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests
// CHECK: Implement a cached list of entities for each component type?

// ℹ️ DESIGN: Pause/unpause should be handled by scene code rather than `OKGameCoordinator` or `OKGameState`, as the scene may be automatically paused by the system when the player receives a call or pulls up the iOS Control Center, for example, but that does not necessarily mean that the GAME has entered a different GAME STATE.
// However, if the player manually pauses, then the scene may signal the `OKGameCoordinator` to enter a "Paused" state, which may or may not then cause a scene transition.

// 🙁 NOTE: This is a large class, but we cannot break it up into multiple files because "Overriding non-@objc declarations from extensions is not supported" as of 2018/03, and other issues with organizing code via extensions: https://github.com/realm/SwiftLint/issues/1767

import SpriteKit
import GameplayKit

public typealias OctopusScene = OKScene

// The top-level unit of visual content in a game. Contains components grouped by entities to represent visual and behavioral elements in the scene. Manages component systems to update components in a deterministic order every frame.
///
/// Includes an entity to represent the scene itself.
open class OKScene: SKScene,
    OKEntityContainerNode,
    OKGameStateDelegate,
    OKEntityDelegate,
    OKSubsceneDelegate,
    SKPhysicsContactDelegate
{
    // ℹ️ Also see SKScene+OctopusKit extensions.
    
    // MARK: - Properties
    
    // MARK: Constants
    
    /// The value to clamp `updateTimeDelta` to, to avoid spikes in frame processing.
    public static let updateTimeDeltaMaximum: TimeInterval = 1.0 / 60.0 // CHECK: What if we want more than 60 FPS? // CREDIT: Apple DemoBots sample
    
    // MARK: Timekeeping
    
    /// Updated in `OKScene.update(_:)` every frame. May be used for implementing time-based behavior and effects.
    ///
    /// - NOTE: Not checked for overflow, to increase performance.
    public fileprivate(set) var secondsElapsedSinceMovedToView: TimeInterval = 0
    
    /// The number of the frame being rendered. The count of frames rendered so far, minus 1.
    ///
    /// Incremented at the beginning of every `update(_:)` call. Used for logging and debugging.
    ///
    /// - NOTE: This property actually denotes the number of times the 'update(_:)' method has been called so far. The actual beginning of a "frame" may happen outside the 'update(_:)' method and may not align with the mutation of this property. 
    public fileprivate(set) var currentFrameNumber: UInt64 = 0
    
    /// Updated in `OKScene.update(_:)` every frame.
    public fileprivate(set) var updateTimeDelta: TimeInterval = 0
    
    /// Updated in `OKScene.update(_:)` every frame.
    public fileprivate(set) var lastUpdateTime: TimeInterval? // CHECK: Should this be optional?
    
    /// Keeps track of the time when the game was paused, so that game elements can resume updating from that time when the game is resumed, instead of at the scene's time which will continue incrementing in every `OKScene.update(_:)`.
    public fileprivate(set) var pausedAtTime: TimeInterval?
    
    // MARK: State & Flags
    
    /// Set to `true` after `createContents()` is called.
    public fileprivate(set) var didCreateContents = false
    
    /// Set to `true` when the game is automatically paused by the system, such as when switching to another app or receiving a call.
    ///
    /// Modified during `OSAppDelegate.applicationDidBecomeActive(_:)` and `OSAppDelegate.applicationWillResignActive(_:)`
    public fileprivate(set) var isPausedBySystem = false
    
    /// Set to `true` when the game is presenting a modal user interface that is waiting for the player's input, while putting the game's action on hold.
    public fileprivate(set) var isPausedBySubscene = false
    
    /// Set to `true` when the game is paused by the player, as opposed to being paused by the system, to display an in-game pause state without affecting actions etc.
    ///
    /// Modified via `pauseByPlayer()` and `unPauseByPlayer()`
    public fileprivate(set) var isPausedByPlayer = false
    
    /// An array of "subscenes" that display self-contained content in an overlay while pausing the main scene, such as pause-effects, modal UI, cutscenes or minigames.
    ///
    /// This is a stack; if there is more than one subscene, only the most-recently-added subscene is updated, and subscenes must be dismissed in a last-in, first-out order.
    public fileprivate(set) var subscenes: [OKSubscene] = []
    
    /// Set to `true` for a single frame after the scene presents a subscene.
    ///
    /// Components can observe this flag to modify or halt their behavior during or after subscene transitions.
    public fileprivate(set) var didPresentSubsceneThisFrame: Bool = false
    
    /// Set to `true` for a single frame after the scene dismisses a subscene.
    ///
    /// Components can observe this flag to modify or halt their behavior during or after subscene transitions.
    public fileprivate(set) var didDismissSubsceneThisFrame: Bool = false
    
    // MARK: Entities & Components
    
    // DESIGN: The `entities` property was supposed to be read-only with `fileprivate(set)`, but has to be made public so that the default implementation extension for the `OKEntityContainer` (which is necessary to avoid duplicating code between `OKScene` and `OKSubscene`) can modify it.
    
    public lazy var entities = Set<GKEntity>()
    
    /// Used for deferring the removal of entities, since modifying the list of entities during a frame update may cause an exception/crash, because of mutating the entities collection while it is being enumerated during the update.
    ///
    /// Since this is a `Set`, it prevents entities from being added more than once.
    public var entitiesToRemoveOnNextUpdate = Set<GKEntity>()
    
    /// The primary array of component systems for this scene. Determines the order in which components of all entities must be updated every frame.
    ///
    /// Component systems are in an `Array` instead of a `Set` because a deterministic order of updates is important for proper game functionality. Further arrays may be created by subclass if more groupings of related systems are required. The `Array+OKComponentSystem` extension contains helper methods to assist with managing arrays of systems.
    ///
    /// - Important: `OKScene` does not update component systems by default, as each game may have its specific logic for updating systems in relation to the paused/unpaused state, etc.
    ///
    /// - Important: The `OKScene` subclass must call `updateSystems(in:deltaTime:)` at some point in the `update(_ currentTime: TimeInterval)` method, usually after handling pause/unpause logic.
    ///
    /// - Important: Adding a system does not automatically register the components from any of the scene's existing entities. Call either `self.componentSystems.addComponents(foundIn:)` to register components from a single entity, or `addAllComponentsFromAllEntities(to:)` to register components from all entities.
    public lazy var componentSystems: [OKComponentSystem] = []
    
    // MARK: Shared Components
    
    // CHECKED: These properties do not seem to prevent the scene from deinit'ing if they're not optionals.
    
    #if canImport(AppKit)
    
    /// Creates a new `MouseEventComponent` when this property is first accessed, and returns that component on subsequent calls.
    ///
    /// This is a convenience for cases such as adding a single event stream to the scene entity, then sharing it between multiple child entities via `RelayComponent`s.
    @available(macOS 10.15, *)
    @available(iOS, unavailable, message: "Use sharedTouchEventComponent or sharedMouseOrTouchEventComponent")
    public fileprivate(set) lazy var sharedMouseEventComponent = MouseEventComponent()
    
    /// Returns `sharedTouchEventComponent` on iOS, or `sharedMouseEventComponent` on macOS.
    @available(macOS 10.15, iOS 13.0, *)
    @inlinable
    public var sharedMouseOrTouchEventComponent: MouseEventComponent { sharedMouseEventComponent }
    
    /// Creates a new `KeyboardEventComponent` when this property is first accessed, and returns that component on subsequent calls.
    ///
    /// This is a convenience for cases such as adding a single event stream to the scene entity, then sharing it between multiple child entities via `RelayComponent`s.
    @available(macOS 10.15, *)
    @available(iOS, unavailable)
    public fileprivate(set) lazy var sharedKeyboardEventComponent = KeyboardEventComponent()
    
    #endif
    
    #if canImport(UIKit)
    
    /// Creates a new `TouchEventComponent` when this property is first accessed, and returns that component on subsequent calls.
    ///
    /// This is a convenience for cases such as adding a single event stream to the scene entity, then sharing it between multiple child entities via `RelayComponent`s.
    @available(iOS 13.0, *)
    @available(macOS, unavailable, message: "Use sharedMouseEventComponent or sharedMouseOrTouchEventComponent")
    public fileprivate(set) lazy var sharedTouchEventComponent = TouchEventComponent()
    
    /// Returns `sharedTouchEventComponent` on iOS, or `sharedMouseEventComponent` on macOS.
    @available(macOS 10.15, iOS 13.0, *)
    @inlinable
    public var sharedMouseOrTouchEventComponent: TouchEventComponent { sharedTouchEventComponent }
    
    /// Creates a new `MotionManagerComponent` when this property is first accessed, and returns that component on subsequent calls.
    ///
    /// This is a convenience for cases such as adding a single motion manager to the scene entity, then sharing it between multiple child entities via `RelayComponent`s.
    @available(iOS 13.0, *)
    @available(macOS, unavailable, message: "You can't shake a Mac!")
    public fileprivate(set) lazy var sharedMotionManagerComponent = MotionManagerComponent()
    
    #endif
    
    /// Creates a new `PointerEventComponent` when this property is first accessed, and returns that component on subsequent calls.
    ///
    /// This is a convenience for cases such as adding a single event stream to the scene entity, then sharing it between multiple child entities via `RelayComponent`s.
    public fileprivate(set) lazy var sharedPointerEventComponent = PointerEventComponent()
    
    /// Creates a new `PhysicsEventComponent` when this property is first accessed, and returns that component on subsequent calls.
    ///
    /// This is a convenience for cases such as adding a single event stream to the scene entity, then sharing it between multiple child entities via `RelayComponent`s.
    public fileprivate(set) lazy var sharedPhysicsEventComponent = PhysicsEventComponent()
    
    // MARK: Other
    
    @inlinable
    public var gameCoordinator: OKGameCoordinator? {
        OctopusKit.shared.gameCoordinator
    }
    
    /// The object which controls scene and game state transitions on behalf of the current scene. Generally the `OKViewController`.
    public var octopusSceneDelegate: OKSceneDelegate? {
        didSet {
            // Cannot use `@LogChanges` because "Protocol type 'OKSceneDelegate' cannot conform to 'Equatable' because only concrete types can conform to protocols"
            OctopusKit.logForDebug("\(oldValue) → \(octopusSceneDelegate)")
        }
    }
    
    /// The list of pathfinding graph objects managed by the scene.
    public var graphs: [String : GKGraph] = [:]
    
    /// Debugging information.
    open override var description: String {
        return "\"\(name == nil ? "" : name!)\" frame = \(frame) size = \(size) anchor = \(anchorPoint) view.frame.size = \(view?.frame.size)"
    }
    
    // MARK: - Life Cycle
    
    public required override init(size: CGSize) {
        // Required so that it may be constructed by metatype values, e.g. `sceneClass.init(size:)`
        // CHECK: Still necessary?
        super.init(size: size)
        self.name = setName()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        // CHECK: Should we `fatalError()` here? // fatalError("init(coder:) has not been implemented")
        self.name = setName()
    }
    
    /// Abstract; override in subclass. Called by the initializers to set the scene's name at the earliest point for logging purposes.
    open func setName() -> String? { nil }
    
    open override func sceneDidLoad() {
        OctopusKit.logForFramework("\(self)")
        super.sceneDidLoad()
        
        // Create and add the entity that represents the scene itself.
        
        if  self.entity == nil {
            createSceneEntity()
        }
        
        // CHECK: Should this be moved to `didMove(to:)`?
        self.lastUpdateTime = 0 // CHECK: nil?
    }
    
    /// An abstract method called by `OKViewController` before the scene is presented in a view. Override this in a subclass to set up scaling etc. before the scene displays any content.
    ///
    /// - Important: This method has to be called manually (e.g. from the `SKView`'s view controller) before presenting the scene. It is not invoked by the system and is *not* guaranteed to be called.
    open func willMove(to view: SKView) {}
    
    /// Calls `createContents()` which may be used by a subclass to create the scene's contents, then adds all components from each entity in the `entities` set to the relevant systems in the `componentSystems` array. If overridden then `super` must be called for proper initialization of the scene.
    open override func didMove(to: SKView) {
        // CHECK: Should this be moved to `sceneDidLoad()`?
        OctopusKit.logForFramework("name = \"\(name ?? "")\", size = \(size), view.frame.size = \(to.frame.size), scaleMode = \(scaleMode.rawValue)")
        
        secondsElapsedSinceMovedToView = 0
        
        if !didCreateContents {
            
            // Convenient customization point for subclasses, so they can have a standard method for setting up the initial list of component systems.
            componentSystems.createSystems(forClasses: createComponentSystems())
            
            OctopusKit.logForFramework("Calling createContents() for \(self)")
            createContents()
            
            // addAllComponentsFromAllEntities(to: self.componentSystems) // CHECK: Necessary? Should we just rely on OKEntityDelegate?
            
            didCreateContents = true // Take care of this flag here so that subclass does not have to do so in `createContents()`.
        }
        
        currentFrameNumber = 1 // Set the frame counter to 1 here because it is incremented in `didFinishUpdate()`, so that logs correctly say the first frame number during the first `update(_:)` method. ⚠️ NOTE: There is still a call to `OKViewController-Universal.viewWillLayoutSubviews()` after this, before the first `update(_:)`. CHECK: Fix?
        
        // Steal the focus on macOS so the player doesn't have to click on the view before using the keyboard.
        // CHECK: Conflicts with SwiftUI etc.
        
        #if os(macOS)
        to.window?.makeFirstResponder(self)
        #endif
    }
    
    /// Creates an entity to represent the scene itself (the root node.)
    ///
    /// This entity may incorporate components to display top-level visual content, such as the user interface or head-up display (HUD), and manage scene-wide subsystems such as input or game turns.
    open func createSceneEntity() {
        // BUG: Setting an `SKScene`'s entity directly with `GKEntity()` causes the scene's entity to remain `nil`, as of 2017/10/13.
        
        // Warn if the scene already has an entity representing it.
        
        if  let existingEntity = self.entity {
            OctopusKit.logForErrors("\(self) already has an entity: \(existingEntity)")
            // CHECK: Remove the existing entity here, or exit the method here?
        }
        
        // Create an entity to represent the scene itself, with an `NodeComponent` and `SceneComponent`.
        
        let sceneEntity = OKEntity(name: self.name, node: self) // NOTE: `node: self` adds a `NodeComponent`.
        sceneEntity.addComponent(SceneComponent(scene: self))
        self.entity = sceneEntity
        addEntity(sceneEntity)
        
        assert(self.entity === sceneEntity, "Could not set scene's entity")
    }
    
    /// Returns an array that specifies the order of execution for components used by this scene. Called after the scene is presented in a view, before `createContents()` is called.
    ///
    /// Override in subclass. The default implementation returns an array of commonly-used systems.
    ///
    /// - IMPORTANT: Components will be updated every frame in the exact order that is specified here, so a component must be listed after its dependencies.
    ///
    /// The `componentSystems` property may be modified again at any time.
    ///
    /// - Returns: An array of component classes, from which the scene's component systems will be created.
    @inlinable
    open func createComponentSystems() -> [GKComponent.Type] {
        // 1: Time and state
        
        let timeAndState = [
            TimeComponent.self,
            StateMachineComponent.self,
            DelayedRemovalComponent.self]
        
        // 2: Player input
        
        var playerInput = [
            OSMouseOrTouchEventComponent.self,
            PointerEventComponent.self]
        
        // Keyboard support on macOS-only
        
        #if canImport(AppKit)
        playerInput.append(KeyboardEventComponent.self)
        #endif
        
        playerInput += [
            DirectionEventComponent.self,
            NodePointerStateComponent.self,
            NodePointerClosureComponent.self]
        
        // 3: Movement and physics
        
        let movementAndPhysics = [
            DirectionControlledRotationComponent.self,
            DirectionControlledTorqueComponent.self,
            DirectionControlledThrustComponent.self,
            DirectionControlledForceComponent.self,
            
            PointerControlledForceComponent.self,
            PointerControlledPositioningComponent.self,
            PointerControlledRotationComponent.self,
            PointerControlledSeekingComponent.self,
            
            AgentComponent.self,
            
            // The physics component should come in after other components have modified node properties, so it can clamp the velocity etc. if such limits have been specified.
            
            PhysicsComponent.self]
        
        // 4: Custom code and anything else that depends on the final placement of nodes per frame.
        
        let miscellaneous = [
            PointerControlledPhysicsHoldingComponent.self,
            PhysicsEventComponent.self,
            
            TimeDependentClosureComponent.self,
            RepeatingClosureComponent.self,
            DelayedClosureComponent.self,
            CameraZoomComponent.self,
            CameraComponent.self]
        
        return timeAndState + playerInput + movementAndPhysics + miscellaneous
    }
    
    /// Abstract; override in subclass. Creates the scene's contents and sets up entities and components. Called after the scene is presented in a view, after `createComponentSystems()`.
    ///
    ///  Called from `didMove(to:)`.
    ///
    /// - NOTE: If the scene requires the global `OctopusKit.shared.gameCoordinator.entity`, add it manually after setting up the component systems, so that the global components may be registered with this scene's systems.
    ///
    /// - NOTE: A scene may also/instead choose to create its contents in the `gameCoordinatorDidEnterState(_:from:)` method.
    @inlinable
    open func createContents() {
        OctopusKit.logForFramework("Not implemented for \(self) — Override in subclass.")
    }
    
    open override func didChangeSize(_ oldSize: CGSize) {
        // CHECK: This is seemingly always called after `init`, before `sceneDidLoad()`, even when the `oldSize` and current `size` are the same.
        super.didChangeSize(oldSize)
        OctopusKit.logForFramework("\(self) — oldSize = \(oldSize) → \(self.size)")
    }
    
    /// By default, removes all entities from the scene when it is no longer in a view, so that the scene may be deinitialized and free up device memory.
    ///
    /// To prevent this behavior, for example in cases where a scene is expected to be presented again and should remain in memory, override this method.
    open override func willMove(from view: SKView) {
        OctopusKit.logForFramework()
        super.willMove(from: view)
        
        // CHECK: Should we delay the teardown of an outgoing scene to prevent any performance hiccups in the incoming scene?
        
        // NOTE: `self.entities` includes `self.entity`, and `removeEntity(_:)` also calls `GKEntity.removeAllComponents()`
        
        for entity in self.entities {
            removeEntity(entity)
        }
        
        // CHECKED: The shared component properties (`sharedTouchEventComponent` etc.) do not seem to prevent the scene from deinit'ing if they're not set to `nil` here.
    }
    
    deinit {
        OctopusKit.logForDeinits("\"\(self.name)\" secondsElapsedSinceMovedToView = \(secondsElapsedSinceMovedToView), lastUpdateTime = \(lastUpdateTime)")
    }
    
    // MARK: - Game State
    
    /// Called by `OKGameState`. To be overridden by a subclass if this same scene is used for different game states, e.g. to present different visual overlays for the paused or "game over" states.
    ///
    /// Call `super` to add default logging.
    open func gameCoordinatorDidEnterState(_ state: GKState, from previousState: GKState?) {
        OctopusKit.logForStates("\(previousState) → \(state)")
    }
    
    /// Called by `OKGameState`. To be overridden by a subclass if this same scene is used for different game states, e.g. to remove visual overlays that were presented during a paused or "game over" state.
    ///
    /// Call `super` to add default logging.
    open func gameCoordinatorWillExitState(_ exitingState: GKState, to nextState: GKState) {
        OctopusKit.logForStates("\(exitingState) → \(nextState)")
    }
    
    /// Abstract; override in subclass to provide a visual transition effect between scenes.
    open func transition(for nextSceneClass: OKScene.Type) -> SKTransition? {
        return nil
    }
    
    // MARK: Entities & Components
    
    // Most of the entity management code as well as `OKEntityDelegate` conformance is provided by the default implementation extensions of the `OKEntityContainer` protocol.
    
    // MARK: - Update Cycle
    
    /// This method is called by SpriteKit on every frame (before `SKAction`s are evaluated) and updates components via component systems.
    ///
    /// This method also performs timer calculations and handles pausing/unpausing logic, entity removal and other preparations that are necessary for every frame.
    ///
    /// An `OKScene` subclass (i.e. the scenes specific to your game) may control pause/unpause behavior and perform other per-frame logic by overriding the `shouldUpdateGameCoordinator(deltaTime:)` and `shouldUpdateSystems(deltaTime:)` methods.
    ///
    /// The preferred pattern in OctopusKit is to simply add entities and components to the scene in a method like `createContents()` or `gameCoordinatorDidEnterState(_:from:)`, and let this method automatically update all component systems, which allows all the per-frame logic for the game to be handled by the `update(_:)` method of each individual component and state class.
    ///
    /// For an overview of the SpriteKit frame cycle, see: https://developer.apple.com/documentation/spritekit/skscene/responding_to_frame-cycle_events
    ///
    /// - IMPORTANT: If this method is overridden, `super.update(currentTime)` **must** be called for correct functionality (before any other code in most cases), and the subclass should also recheck `isPaused`, `isPausedBySystem`, `isPausedByPlayer` and `isPausedBySubscene` flags.
    public override func update(_ currentTime: TimeInterval) {
        
        // #1: Reset single-frame flags.
        
        didPresentSubsceneThisFrame = false
        didDismissSubsceneThisFrame = false
        
        // MARK: Entity Removal
        
        // #2: If any entities were marked for removal since the last update, remove them now.
        // This delayed removal is done to avoid mutating the entities collection while it is being enumerated within the same frame update.
        
        for entityToRemove in entitiesToRemoveOnNextUpdate {
            removeEntity(entityToRemove)
        }
        
        entitiesToRemoveOnNextUpdate.removeAll()
        
        // MARK: Timekeeping
        
        // #3: Track the time and handle pausing/unpausing so that components and states may be correctly updated.
        
        // THANKS: http://stackoverflow.com/questions/24728881/calculating-delta-in-spritekit-using-swift
        
        // If the scene has been paused by the system, player or UI, just record the time and exit the method.
        
        // ℹ️ Keeping track of the `pausedAtTime` lets us implement "soft" pauses, where the scene may still receive calls to the `update(_:) method, in order to update visuals, audio and the user interface (e.g. via SpriteKit actions) but the game's logic remains paused.
        
        // ℹ️ The exact consequences of each of the `isPaused...` flags are specific to each game. Some games may choose to prevent the `update(_:)` method from being called at all during a paused state. Other games may simply stop the movement of game characters while continuing to update other elements.
        
        // NOTE: The subclass's implementation must also handle the `isPaused...` flags.
        
        // NOTE: The `isPausedBySubscene` flag is a special case, and should only be handled by the subclass. The engine itself should continue so that the subscenes can be updated.
        
        guard
            !isPaused,
            !isPausedBySystem,
            !isPausedByPlayer
            else
        {
            if  pausedAtTime == nil {
                pausedAtTime = currentTime
                
                OctopusKit.logForFramework("pausedAtTime = \(pausedAtTime!), isPaused = \(isPaused), isPausedBySystem = \(isPausedBySystem), isPausedByPlayer = \(isPausedByPlayer), isPausedBySubscene = \(isPausedBySubscene)")
            }
            
            return
        }
        
        // If this is not our first frame, calculate the time elapsed (`updateTimeDelta`) between the current frame and the previous frame.
        
        if  let lastUpdateTime = self.lastUpdateTime {
            
            // ℹ️ Cannot use the overflow `&+` operator with `Double`, if you're thinking of allowing overflows for `secondsElapsedSinceMovedToView` to increase performance a little.
            
            self.secondsElapsedSinceMovedToView += (currentTime - lastUpdateTime)
            
            // If we were previously paused, disregard the time spent in the paused state.
            
            if  let pausedAtTime = self.pausedAtTime {
                
                // Subtract the `lastUpdateTime` from `pausedAtTime` instead of `currentTime`, so that the behavior of components and states appears to continue from the moment when the game was paused.
                
                self.updateTimeDelta = pausedAtTime - lastUpdateTime
                
                // Forget the paused time and clear the instance property as we are no longer paused.
                
                self.pausedAtTime = nil
                
            } else {
                // If we were not paused, calculate the delta value as normal.
                self.updateTimeDelta = currentTime - lastUpdateTime
            }
            
        } else {
            // If this is our very first frame, simply zero the delta value.
            self.updateTimeDelta = 0
        }
        
        // Record the current time for the next frame.
        
        self.lastUpdateTime = currentTime
        
        // If more than `updateTimeDeltaMaximum` has passed, clamp `updateTimeDelta` to the maximum desirable value; otherwise use `deltaTime`.
        
        // NOTE: Sometimes the delta may spike. This occurs at the beginning of the game (for the first few frames as things are still being loaded into memory) and occasionally when something else happens on the device (like when a system notification comes in). By capping the delta value we reduce the chance of getting a time step that is too large, preventing elements from "jumping" around erratically.
        
        // THANKS: http://www.raywenderlich.com/62049/sprite-kit-tutorial-make-platform-game-like-super-mario-brothers-part-1
        // THANKS: Apple DemoBots sample
        
        updateTimeDelta = updateTimeDelta > OKScene.updateTimeDeltaMaximum ? OKScene.updateTimeDeltaMaximum : updateTimeDelta
        
        // MARK: Subscene
        
        // #4: Update the most-recently-added subscene.
        
        if  let subscene = self.subscenes.last {
            subscene.update(deltaTime: updateTimeDelta)
        }
        
        // #5: Call the game coordinator's update method in case the game uses per-frame logic in a subclass of `OKGameCoordinator`.
        
        if  self.shouldUpdateGameCoordinator(deltaTime: updateTimeDelta) {
            OctopusKit.shared.gameCoordinator.update(deltaTime: updateTimeDelta)
        }
        
        // #6: Update components and systems in the subclass.
        
        if  self.shouldUpdateSystems(deltaTime: updateTimeDelta) {
            updateSystems(in: componentSystems, deltaTime: updateTimeDelta)
        }
        
    }
    
    /// This method is called at the end of `OKScene.update()` to determine whether to call `OctopusKit.shared.gameCoordinator.update()` on every frame.
    ///
    /// If the game uses a custom subclass of `OKGameCoordinator` that implements an `update(deltaTime:)` method then an `OKScene` subclass may override `shouldUpdateGameCoordinator(deltaTime:)` to customize the per-frame logic.
    ///
    /// This method is called before `shouldUpdateSystems()` during the frame update.
    ///
    /// - RETURNS: The default implementation calls `shouldUpdateSystems` and forwards its result.
    open func shouldUpdateGameCoordinator(deltaTime: TimeInterval) -> Bool {
        return shouldUpdateSystems(deltaTime: deltaTime)
    }
    
    /// This method is called at the end of `OKScene.update()` on every frame to determine whether to update all systems in the `componentSystems` array.
    ///
    /// An `OKScene` subclass may override this method to customize pause/unpause behavior or other logic to control the updates of component systems.
    ///
    /// This method is called after `shouldUpdateGameCoordinator()` during the frame update.
    ///
    /// - RETURNS: The default implementation returns `true` if **none** of the paused flags are set: `!isPaused && !isPausedBySystem && isPausedByPlayer && !isPausedBySubscene`
    open func shouldUpdateSystems(deltaTime: TimeInterval) -> Bool {
        return (!isPaused && !isPausedBySystem && !isPausedByPlayer && !isPausedBySubscene)
    }
    
    /// Increments the frame counter at the end of the current frame update.
    ///
    /// - IMPORTANT: A subclass that overrides this method must call `super.didFinishUpdate()` at the end of its implementation to properly increment the frame counter.
    open override func didFinishUpdate() {
        // Increment the frame count for use in logging and debugging.
        
        // ℹ️ CHECK: PERFORMANCE: Although it makes more sense for `currentFrameNumber` to be incremented in `didFinishUpdate()` (which also eliminates the confusion from seemingly processing input events with a 1-frame lag, according to the logs, because they're received before `update(_:)` is called), we could increment it in `update(_:)` for more performance by calling one less method.
        
        // ℹ️ PERFORMANCE: Allow overflows for `currentFrameNumber` because a `UInt64` is large enough and it improves performance, and the `currentFrameNumber` should mostly be used for logging anyway so it doesn't matter much if it wraps around.
        
        currentFrameNumber = currentFrameNumber &+ 1
    }
    
    // MARK: - Physics
    
    /// Relay physics contact events to the scene's `PhysicsEventComponent`.
    open func didBegin(_ contact: SKPhysicsContact) {
        
        if  let physicsEventComponent = self.entity?.componentOrRelay(ofType: PhysicsEventComponent.self) {
            physicsEventComponent.contactBeginnings.append(PhysicsEventComponent.ContactEvent(contact: contact, scene: self))
        }
    }
    
    /// Relay physics contact events to the scene's `PhysicsEventComponent`.
    open func didEnd(_ contact: SKPhysicsContact) {
        
        if  let physicsEventComponent = self.entity?.componentOrRelay(ofType: PhysicsEventComponent.self) {
            physicsEventComponent.contactEndings.append(PhysicsEventComponent.ContactEvent(contact: contact, scene: self))
        }
    }
    
    // MARK: - Pause/Unpause
    
    /// Called by `OSAppDelegate.applicationWillEnterForeground(_:)`. Subclass to implement custom behavior such as going into a player-paused visual state.
    ///
    /// - Important: The overriding implementation must call `super.applicationWillEnterForeground()`.
    open func applicationWillEnterForeground() {
        OctopusKit.logForFramework()
        
        if  isPausedBySystem {
            // CHECK: Should `OKScene.applicationDidBecomeActive()` be called from here too, or should we let `OSAppDelegate.applicationDidBecomeActive(_:)` call it?
            applicationDidBecomeActive()
        }
        
        // TODO: audioEngine.startAndReturnError()
    }
    
    /// Called by `OSAppDelegate.applicationDidBecomeActive()` after the player has switched back into the app or interruptions such as a phone call or Control Center have ended.
    ///
    /// - Important: The overriding implementation must call `super.applicationDidBecomeActive()`.
    open func applicationDidBecomeActive() {
        // NOTE: This method gets superfluously called twice after `OSAppDelegate.applicationWillEnterForeground(_:)` because of `OKScene.applicationWillEnterForeground()` and `OSAppDelegate.applicationDidBecomeActive(_:)`.
        
        OctopusKit.logForFramework("isPausedBySystem = \(isPausedBySystem)\(isPausedBySystem ? " → false" : "")")
        
        if  isPausedBySystem {
            isPaused = false
            isPausedBySystem = false
            physicsWorld.speed = 1
            
            // TODO: audioEngine.unduckMusicVolume()
            
            didUnpauseBySystem() // Allow the subclass to customize the pause/unpause behavior.
        }
    }
    
    /// Called by `OSAppDelegate.applicationWillResignActive(_:)` when the player switches out of the app, or on interruptions such as a phone call, Control Center, Notification Center, or other system alerts.
    open func applicationWillResignActive() {
        OctopusKit.logForFramework("isPausedBySystem = \(isPausedBySystem)\(isPausedBySystem ? "" : " → true")")
        
        pausedAtTime = lastUpdateTime // CHECK: Should we rely on the stored value instead of getting current time? Probably yes.
        isPausedBySystem = true
        isPaused = true
        physicsWorld.speed = 0
        
        // TODO: audioEngine.duckMusicVolume()
        
        didPauseBySystem() // Allow the subclass to customize the pause/unpause behavior.
    }
    
    /// Called by `OSAppDelegate.applicationDidEnterBackground(_:)`
    open func applicationDidEnterBackground() {
        OctopusKit.logForFramework()
        
        if  !isPausedBySystem {
            applicationWillResignActive()
        }
        pausedAtTime = lastUpdateTime // CHECK: Should we rely on stored value instead of getting current time? Probably yes
        audioEngine.pause() // CHECK: Should the audio engine be paused here?
    }
    
    /// An abstract method for a subclass to customize scene behavior when the game is paused by a system event.
    ///
    /// Called from `OKScene.applicationWillResignActive()`.
    ///
    /// - NOTE: If the `OKGameCoordinator` includes paused/unpaused game states, an `OKScene` subclass should manually signal the game coordinator to transition between those states here.
    ///
    /// - NOTE: Set the scene's `physicsWorld.speed = 0` in your implementation to pause physics if needed.
    open func didPauseBySystem() {}
    
    /// An abstract method for a subclass to customize scene behavior when the game is unpaused by a system event.
    ///
    /// Called from `OKScene.applicationDidBecomeActive()`.
    ///
    /// - NOTE: If the `OKGameCoordinator` includes paused/unpaused game states, an `OKScene` subclass should manually signal the game coordinator to transition between those states here.
    ///
    /// - NOTE: Set the scene's `physicsWorld.speed = 1` in your implementation to resume physics if needed.
    open func didUnpauseBySystem() {}
    
    /// To be called when the player manually chooses to pause or unpause.
    ///
    /// When paused by the player, the gameplay and other game-specific logic is put on hold without preventing the scene from processing frame updates so the visual effects for a paused state can be shown and animated etc.
    open func togglePauseByPlayer() {
        OctopusKit.logForFramework("isPausedByPlayer = \(isPausedByPlayer) → \(!isPausedByPlayer)")
        
        isPausedByPlayer = !isPausedByPlayer
        
        if  isPausedByPlayer {
            pausedAtTime = lastUpdateTime // CHECK: Should we rely on stored value instead of getting current time?
            // self.physicsWorld.speed = 0.0 // Put in subclass implementation if needed.
            // TODO: audioEngine.duckMusicVolume()
            didPauseByPlayer()
        } else {
            // self.physicsWorld.speed = 1.0 // Put in subclass implementation if needed.
            // TODO: audioEngine.unduckMusicVolume()
            didUnpauseByPlayer()
        }
    }
    
    /// An abstract method for a subclass to customize scene behavior when the game is paused by the player.
    ///
    /// - NOTE: If the `OKGameCoordinator` includes paused/unpaused game states, an `OKScene` subclass should manually signal the game coordinator to transition between those states here.
    ///
    /// - NOTE: Set the scene's `physicsWorld.speed = 0` in your implementation to pause physics if needed.
    open func didPauseByPlayer() {}
    
    /// An abstract method for a subclass to customize scene behavior when the game is unpaused by the player.
    ///
    /// - NOTE: If the `OKGameCoordinator` includes paused/unpaused game states, an `OKScene` subclass should manually signal the game coordinator to transition between those states here.
    ///
    /// - NOTE: Set the scene's `physicsWorld.speed = 1` in your implementation to resume physics if needed.
    open func didUnpauseByPlayer() {}
    
    /// To be called when a modal user interface, such as an alert or other dialog which demands player attention, begins or finishes.
    ///
    /// When paused by modal UI, the gameplay and other game-specific logic is put on hold until the player completes the interaction, without preventing the scene from processing frame updates so that the user interface can continue to be displayed.
    ///
    /// - NOTE: Set the scene's `physicsWorld.speed` to `0` or `1` in your implementation to pause and unpause physics if needed.
    open func togglePauseBySubscene() {
        OctopusKit.logForFramework("isPausedBySubscene = \(isPausedBySubscene) → (!isPausedBySubscene)")
        
        isPausedBySubscene = !isPausedBySubscene
        
        if  isPausedBySubscene {
            pausedAtTime = lastUpdateTime // CHECK: Should we rely on stored value instead of getting current time?
            // self.physicsWorld.speed = 0.0 // Put in subclass implementation if needed.
        } else {
            // self.physicsWorld.speed = 1.0 // Put in subclass implementation if needed.
        }
        
    }
    
    // MARK: - Resizing & Scaling
    
    /// Sets the size of the scene to half the size of the specified view, and sets the `scaleMode` to `aspectFit`.
    ///
    /// For "pixel-perfect" pixel art, you may want to decrease the scene's size by an even factor, then render your bitmaps at `1:1` and let the scene double their size.
    open func halveSizeAndFit(in view: SKView) {
        self.size = view.frame.size.halved
        self.scaleMode = .aspectFit
    }
    
    /// Modifies the scene's scale to match the scene's height to the height of the specified view, cropping the left and right edges of the scene if necessary.
    open func cropAndScaleToFitLandscape(in view: SKView) {
        // CREDIT: Apple Dispenser sample, for landscape-fitted scaling.
        
        let scaleFactor = self.size.height / view.bounds.height // Resize the scene to better use the device aspect ratio.
        self.size.width = view.bounds.width * scaleFactor // If this app runs only in landscape, height always determines scale.
        self.scaleMode = .aspectFit // Set the scale mode to scale to fit the window
    }
    
    /// Modifies the scene's scale to match the scene's width to the width of the specified view, cropping the top and bottom edges of the scene if necessary.
    open func cropAndScaleToFitPortrait(in view: SKView) {
        // CREDIT: Apple Dispenser sample, modified for portrait-fitted scaling.
        
        let scaleFactor = self.size.width / view.bounds.width // Resize the scene to better use the device aspect ratio.
        self.size.height = view.bounds.height * scaleFactor // If this app runs only in portrait, width always determines scale.
        self.scaleMode = .aspectFit // Set the scale mode to scale to fit the window
    }
    
    // MARK: - Subscenes
    
    /// Presents a subscene and pauses the gameplay.
    open func presentSubscene(_ subscene: OKSubscene,
                              onNode parent: SKNode? = nil,
                              zPosition: CGFloat? = nil)
    {
        // CHECK: Should there be a limit on the maximum number of subscenes?
        
        // Check if the specified subscene is already being presented.
        
        guard !self.subscenes.contains(subscene) else {
            OctopusKit.logForWarnings("\(subscene) already in \(self.subscenes)")
            return
        }
        
        // If no parent node was specified, try adding the subscene to the camera if one is present, otherwise just add it as a direct child of this scene.
        
        let parent = parent ?? self.camera ?? self
        
        OctopusKit.logForFramework("\(subscene) on \(parent) at zPosition \(zPosition)")
        
        // Set the subscene's properties.
        
        if  let zPosition = zPosition {
            subscene.zPosition = zPosition
        }
        
        subscene.delegate = self
        
        // Tell the subscene to create its contents for the specified parent.
        // ℹ️ Must be done after setting the delegate so the subscene can notify it.
        
        subscene.createContents(for: parent)
        
        // Add the subscene to the scene and to the array of active subscenes.
        
        parent.addChild(subscene)
        self.subscenes.append(subscene)
        
        // Pause the main gameplay.
        
        if !isPausedBySubscene {
            togglePauseBySubscene()
        }
        
        // Set the subscene presentation flag.
        // CHECK: Should this be set first so that the subscene may use it?
        
        didPresentSubsceneThisFrame = true
        
    }
    
    // MARK: OKSubsceneDelegate
    
    /// A point where `OKScene` subclasses can prepare for presenting a subscene, such as dimming and pausing gameplay nodes.
    open func subsceneWillAppear(_ subscene: OKSubscene, on parentNode: SKNode) {}
    
    /// A point where `OKScene` subclasses can react to the disappearance of a subscene, such as resuming gameplay nodes, and handle its result if any.
    ///
    /// - Important: The overriding implementation must call `super.subsceneDidFinish(subscene, withResult: result)` for `OKScene` to correctly remove the subscene and unpause the game.
    open func subsceneDidFinish(_ subscene: OKSubscene,
                                withResult result: OKSubsceneResultType?)
    {
        OctopusKit.logForFramework("\(subscene) result = \(result)")
        
        if  let index = self.subscenes.firstIndex(of: subscene) {
            self.subscenes.remove(at: index) // ⚠️ CHECK: Will this cause a mutating-while-enumerating exception?
        } else {
            OctopusKit.logForWarnings("\(subscene) not in the subscene list of \(self)")
        }
        
        subscene.removeFromParent()
        
        if  self.subscenes.count < 1 && isPausedBySubscene {
            togglePauseBySubscene()
        }
        
        // Set the subscene dismissal flag.
        
        didDismissSubsceneThisFrame = true
    }
    
    // MARK: - Debugging
    
    open func debugListEntitiesAndComponents() {
        debugLog("""
            🐙
            🔲 Scene = \(self)
            🔶 \(entities.count) Entities...
            """)
        
        for entity in entities {
            debugLog("🔹 \(entity)")
            debugLog("\(entity.components.count) components = \(entity.components)")
        }
        
        debugLog("🔶 \(componentSystems.count) Component Systems...")
        
        for componentSystem in componentSystems {
            debugLog("⚙️ \(componentSystem) componentClass = \(componentSystem.componentClass)")
            debugLog("components = \(componentSystem.components)")
        }
    }
    
}
