//
//  OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017-06-05
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import CoreData

#if os(iOS) // CHECK: Include tvOS?

import CoreMotion

#endif

/// Holds references to top-level objects such as the `gameCoordinator` and its `currentScene`, as well as various logs, which all other OctopusKit objects may need to access at any time.
///
/// One of the core objects for an OctopusKit game, along with `OKGameCoordinator` and `OKViewController`.
///
/// The `OctopusKit` class represents the global environment for an OctopusKit application via its `shared` singleton instance, while the functionality *specific to your game* is managed by `OKGameCoordinator` or your subclass of that.
///
/// **Usage**
///
/// 1. Your application's launch cycle must initialize an instance of `OKGameCoordinator` or its subclass, specifying a list of all possible states your game can be in, represented by `OKGameState`. Each state must have an `OKGameScene` associated with, as well as an optional `SwiftUI` overlay view. See the documentation for `OKGameCoordinator`.
///
/// 2. Call `OctopusKit(gameCoordinator:)` to initialize the `OctopusKit.shared` singleton instance, which all other objects will refer to when they need to access the game coordinator and other top-level objects.
///
/// 3. Use an `OKViewController` in your UI hierarchy to present the game coordinator's scenes.
///
/// - NOTE: The recommended way to setup and present an OctopusKit game is to use the `OKContainerView` for **SwiftUI**.
public final class OctopusKit {
    
    // ℹ️ Tried to make this a generic type for convenience in using different `OKGameCoordinator` subclasses, but it's not possible because "Static stored properties not supported in generic types" as of 2018-04-14.
    
    // CHECK: PERFORMANCE: Make `shared` non-nil for better performance? Could just default it to a dummy `OctopusKit` instance.
    
    /// Returns the singleton OctopusKit instance, which must be created via `initSharedInstance(gameName:gameCoordinator:)` during `AppDelegate.applicationWillLaunchOctopusKit()`.
    public private(set) static var shared: OctopusKit! {
        
        willSet {
            guard OctopusKit.shared == nil else {
                fatalError("OctopusKit: Attempting to set OctopusKit.shared again after the singleton has already been initialized.")
            }
        }
        
        didSet {
            guard oldValue == nil else {
                fatalError("OctopusKit: OctopusKit.shared set again after the singleton has already been initialized.")
            }
            if  let singleton = OctopusKit.shared {
                OctopusKit.logForFramework("\(singleton) initialized.")
            }
        }
    }
        
    public static var initialized: Bool = false
    
    // MARK: - App-specific Settings
    
    /// The name of the app bundle which this game will be deployed with.
    ///
    /// - Important: Should be the same as the `CFBundleName` property in the `Info.plist` file.
    ///
    /// Used for alerts, logs and accessing the Core Data persistent container and other resources related to the bundle name.
    public let appName: String
    
    // public var startupLoader: (() -> Void)?
    
    // MARK: - Top-Level Objects
    
    /// The root coordinator object that manages the various states of the game, as well as any global objects that must be shared across states and scenes.
    ///
    /// - Important: The game's first scene must be specified via the game coordinator's initial state.
    public let gameCoordinator: OKGameCoordinator
    
    @inlinable
    public var gameCoordinatorView: SKView? {
        // ⚠️ - Warning: Trying to access this at the very beginning of the application results in an exception like "Simultaneous accesses to 0x100e8f748, but modification requires exclusive access", so users should delay it by checking something like `gameCoordinator.didEnterInitialState`
        if  let viewController = self.gameCoordinator.viewController,
            let view = viewController.view as? SKView
        {
            return view
        } else {
            OctopusKit.logForDebug("Cannot access gameCoordinator.viewController?.view as an SKView.")
            return nil
        }
    }
    
    @inlinable
    public var currentScene: OKScene? {
        gameCoordinator.currentScene
    }
    
    // MARK: - App-wide Singletons

    #if canImport(UIKit)
    
    /// Currently Unimplemented
    public lazy var managedObjectContext: NSManagedObjectContext? = {
        return nil
        /*
        guard let appDelegate = UIApplication.shared.delegate as? OSAppDelegate else {
            // CHECK: Warning or error?
            fatalError("Cannot access UIApplication.shared.delegate as an OSAppDelegate.")
        }
        
        return appDelegate.persistentContainer.viewContext
        */
    }()
    
    #elseif canImport(AppKit)
    
    /// Currently Unimplemented
    public lazy var managedObjectContext: NSManagedObjectContext? = {
        return nil
        /*
        guard let appDelegate = NSApplication.shared.delegate as? OSAppDelegate else {
            // CHECK: Warning or error?
            fatalError("Cannot access UIApplication.shared.delegate as an OSAppDelegate.")
        }
        
        return appDelegate.persistentContainer.viewContext
        */
    }()
    
    #endif
    
    #if os(iOS) // Not tvOS because TVs don't move :)
    
    /// As per Apple documentation: An app should create only a single instance of the `CMMotionManager` class, as multiple instances of this class can affect the rate at which data is received from the accelerometer and gyroscope.
    public static var motionManager: CMMotionManager? = {
        // CHECK: Should this be optional?
        // CHECK: When to stop device updates? On scene `deinit` or elsewhere?
        CMMotionManager()
    }()
    
    #endif
    
    /// Options for customizing OctopusKit for the current project.
    static var configuration = OKConfiguration()
    
    // MARK: - Instance Methods
    
    /// Initializes the `OctopusKit.shared` singleton instance.
    ///
    /// - Important: Calling this initializer more than once will raise a fatal error.
    ///
    /// - Parameter appNameOverride: The name of the app bundle. Used to retrieve the Core Data store and for logs. If omitted or `nil` the `CFBundleName` property from the `Info.plist` file will be used.
    /// - Returns: Discardable; there is no need store the return value of this initializer.
    @discardableResult public init(appNameOverride: String? = nil,
                                   gameCoordinator: OKGameCoordinator) throws
    {
        guard OctopusKit.shared == nil else {
            throw OKError.invalidConfiguration("OctopusKit: OctopusKit(appName:gameCoordinator:) called again after OctopusKit.shared singleton has already been initialized.")
        }
        
        guard   let appName = appNameOverride
                ?? (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) // There is no `kCFBundleDisplayNameKey` の＿の
                ?? (Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String)
        else {
            throw OKError.invalidConfiguration("Cannot read CFBundleName from Info.plist as a String, and appNameOverride not provided.")
        }
            
        self.appName = appName
        self.gameCoordinator = gameCoordinator
        
        OctopusKit.shared = self
        OctopusKit.initialized = true
    }
    
    /// Ensures that the OctopusKit has been correctly initialized.
    @discardableResult public static func verifyConfiguration() throws -> Bool {
        guard let singleton = OctopusKit.shared else {
            throw OKError.invalidConfiguration("OctopusKit.shared singleton not initialized. Call OctopusKit(gameCoordinator:) or OKViewController(gameCoordinator:) during application launch.")
        }
        guard !singleton.appName.isEmpty else {
            // CHECK: More rigorous verification? Compare with `CFBundleName` from `Info.plist`?
            throw OKError.invalidConfiguration("OctopusKit.shared.appName is empty.")
        }
        return true
    }
}
