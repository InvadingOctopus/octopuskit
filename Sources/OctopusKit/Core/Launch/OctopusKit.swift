//
//  OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017-06-05
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import CoreData

#if os(iOS) // CHECK: Include tvOS?

import CoreMotion

#endif

/// The centralized point of control and coordination for the OctopusKit.
///
/// ----
///
/// **Usage:**
/// Your `AppDelegate` class must inherit from `OctopusAppDelegate`, and it must only implement `applicationWillLaunchOctopusKit()` — other system events are handled by the engine.
///
/// Your view controller for the SpriteKit view must inherit from `OctopusSceneController`, and your scenes must inherit from `OctopusScene`.
///
/// Your `AppDelegate` must call `OctopusKit(appName:gameController:)` to initialize the `OctopusKit.shared` singleton instance, specifying a `OctopusGameController` or its subclass, with a list of `OctopusGameState`s and their associated scenes.
///
/// - Note: The `OctopusKit` class contains the top-level objects common to launching all games based on the engine and interfacing with the operating system, but the functionality *specific to your game* is coordinated by `OctopusGameController` or your subclass of it.
public final class OctopusKit {
    
    // ℹ️ Tried to make this a generic type for convenience in using different `OctopusGameController` subclasses, but it's not possible because "Static stored properties not supported in generic types" as of 2018-04-14.
    
    // CHECK: PERFORMANCE: Make `shared` non-nil for better performance? Could just default it to a dummy `OctopusKit` instance.
    
    /// Returns the singleton OctopusKit instance, which must be created via `initSharedInstance(gameName:gameController:)` during `AppDelegate.applicationWillLaunchOctopusKit()`.
    public fileprivate(set) static var shared: OctopusKit? {
        willSet {
            guard OctopusKit.shared == nil else {
                fatalError("OctopusKit: Attempting to set OctopusKit.shared again after the singleton has already been initialized.")
            }
        }
        didSet {
            guard oldValue == nil else {
                fatalError("OctopusKit: OctopusKit.shared set again after the singleton has already been initialized.")
            }
            if let singleton = OctopusKit.shared {
                OctopusKit.logForFramework.add("\(singleton) initialized.")
            }
        }
    }
        
    // MARK: - App-specific Settings
    
    /// The name of the app bundle which this game will be deployed with.
    ///
    /// - Note: Should be the same as the `CFBundleName` property in the `Info.plist` file.
    ///
    /// Used for alerts, logs and accessing the Core Data persistent container and other resources related to the bundle name.
    public let appName: String
    
    // public var startupLoader: (() -> Void)?
    
    // MARK: - Top-Level Objects
    
    /// The root controller object that manages the various states of the game, as well as any global objects that must be shared across states and scenes.
    /// - Important: Must specify the first scene via its initial state.
    public let gameController: OctopusGameController
    
    #if os(iOS)
    public var sceneController: OctopusSceneController? {
        // CHECK: Should we return as `OctopusSceneController`?
        // CHECK: Should this be a stored property set by the `OctopusSceneController` instance?
        if let sceneController = UIApplication.shared.delegate?.window??.rootViewController as? OctopusSceneController { // CHECK: Is there a better way? Storyboard/IB binding?
            return sceneController
        }
        else {
            OctopusKit.logForErrors.add("Cannot access UIApplication.shared.delegate.window.rootViewController as an OctopusSceneController.")
            return nil
        }
    }
    
    #elseif os(OSX)
    public var sceneController: OctopusSceneController? {
        // CHECK: Should we return as `OctopusSceneController`?
        // CHECK: Should this be a stored property set by the `OctopusSceneController` instance?
        // TODO: Multi-window support?
        if let sceneController = NSApplication.shared.keyWindow?.contentViewController as? OctopusSceneController { // CHECK: Is there a better way? Storyboard/IB binding?
            return sceneController
        }
        else {
            OctopusKit.logForErrors.add("Cannot access NSApplication.shared.mainWindow.contentViewController as an OctopusSceneController.")
            return nil
        }
    }
    
    #endif
    
    public var sceneControllerView: SKView? {
        // ⚠️ Trying to access this at the very beginning of the application results in an exception like "Simultaneous accesses to 0x100e8f748, but modification requires exclusive access", so users should delay it by checking something like `gameController.didEnterInitialState`
        if  let sceneController = self.sceneController,
            let view = sceneController.view as? SKView
        {
            return view
        }
        else {
            OctopusKit.logForErrors.add("Cannot access UIApplication.shared.delegate.window.rootViewController.view as an SKView.")
            return nil
        }
    }
    
    public var currentScene: OctopusScene? {
        // CHECK: Should we return as `SKScene`?
        if  let view = self.sceneControllerView,
            let scene = view.scene as? OctopusScene
        {
            return scene
        }
        else {
            //  OctopusKit.logForWarnings.add("Cannot access UIApplication.shared.delegate.window.rootViewController.view.scene as an OctopusScene")
            return nil
        }
    }
    
    // MARK: - App-wide Singletons

    #if os(iOS)
    
    public lazy var managedObjectContext: NSManagedObjectContext? = {
        
        guard let appDelegate = UIApplication.shared.delegate as? OctopusAppDelegate else {
            // CHECK: Warning or error?
            fatalError("Cannot access UIApplication.shared.delegate as an OctopusAppDelegate.")
        }
        
        return appDelegate.persistentContainer.viewContext
    }()
    
    #endif
    
    #if canImport(CoreMotion) // #if os(iOS) // CHECK: Include tvOS?
    
    /// As per Apple documentation: An app should create only a single instance of the `CMMotionManager` class, as multiple instances of this class can affect the rate at which data is received from the accelerometer and gyroscope.
    public static var motionManager: CMMotionManager? = {
        // CHECK: Should this be optional?
        // CHECK: When to stop device updates? On scene `deinit` or elsewhere?
        return CMMotionManager()
    }()
    
    #endif
    
    // MARK: - Instance Methods
    
    /// Initializes the `OctopusKit.shared` singleton instance.
    ///
    /// - Important: Calling this initializer more than once will raise a fatal error.
    ///
    /// - Parameter appName: The name of the app bundle. Should be the same as the `CFBundleName` property in the `Info.plist` file.
    /// - Parameter gameController: An instance of `OctopusGameController` or its subclass, specifying the possible game states and their associated scenes.
    /// - Returns: Discardable; there is no need store the return value of this initializer.
    @discardableResult public init(appName: String,
                                   gameController: OctopusGameController)
    {
        guard OctopusKit.shared == nil else {
            fatalError("OctopusKit: OctopusKit(appName:gameController:) called again after OctopusKit.shared singleton has already been initialized.")
        }
        
        self.appName = appName
        self.gameController = gameController
        
        OctopusKit.shared = self
    }
    
    /// Ensures that the OctopusKit has been correctly initialized.
    @discardableResult public static func verifyConfiguration() -> Bool {
        guard let singleton = OctopusKit.shared else {
            fatalError("OctopusKit: OctopusKit.shared singleton not initialized.")
        }
        guard !singleton.appName.isEmpty else {
            // TODO: More rigorous verification; compare with `CFBundleName` in `Info.plist`?
            fatalError("OctopusKit: OctopusKit.shared.appName is empty.")
        }
        return true
    }
}
