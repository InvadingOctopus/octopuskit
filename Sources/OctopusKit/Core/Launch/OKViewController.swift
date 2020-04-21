//
//  OKViewController.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/24.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Seek a cleaner way to mix iOS- and macOS-specific code?

import SpriteKit
import GameplayKit

#if os(iOS) // CHECK: Include tvOS?

import UIKit

#elseif os(macOS)

import Cocoa

#endif

public typealias OctopusViewController = OKViewController

/// Manages a SpriteKit `SKView` to present the game's scenes and handles device presentation such as rotation orientations.
///
/// One of the core objects for an OctopusKit game, along with `OctopusKit` and `OKGameCoordinator`.
///
/// **Usage**
///
/// 1. Use the `OctopusKit` and `OKGameCoordinator` initializers in your application's launch cycle to setup your game's structure.
///
/// 2. Connect a `OKViewController` (or its subclass) in your UI view hierarchy with the `OKGameCoordinator` to present your game's content. There are multiple ways to do this:
///
///     * Via code.
///
///     * Via the `OKContainerView` or `OKViewControllerRepresentable` in a SwiftUI application (macOS, iOS and tvOS.)
///
///     * Via Storyboards in an AppKit (macOS) or UIKit (iOS, tvOS) application.
///
/// 3. The `OKViewController` will present the current scene of your `OKGameCoordinator` in the SpriteKit view.
///
/// - NOTE: The recommended way to setup and present an OctopusKit game is to use the `OKContainerView` for **SwiftUI**.
open class OKViewController: OSViewController {
    
    public fileprivate(set) var spriteKitView: SKView?
    
    public unowned var gameCoordinator: OKGameCoordinator? {
        didSet {
            // Display the ongoing scene of the new game coordinator, if any.
            if  oldValue !== gameCoordinator,
                let ongoingScene = gameCoordinator?.currentScene,
                let spriteKitView = self.spriteKitView
            {
                spriteKitView.presentScene(ongoingScene)
                ongoingScene.didUnpauseBySystem()
            }
        }
    }
    
    // MARK: - Life Cycle
    
    public required init(gameCoordinator: OKGameCoordinator? = nil) throws {
        
        // To support easy SwiftUI usage...
        
        if  let gameCoordinator = gameCoordinator {
            
            if  let existingGameCoordinator = OctopusKit.shared?.gameCoordinator,
                gameCoordinator !== existingGameCoordinator
            {
                throw OKError.invalidConfiguration("OctopusKit already running with \(existingGameCoordinator) — OKViewController initialized with \(gameCoordinator)")
            }
            
            // Initialize OctopusKit if we're the very first view controller.
            // Putting this here reduces the boilerplate required by SwiftUI applications.
            
            if  OctopusKit.shared?.gameCoordinator == nil {
                try OctopusKit(gameCoordinator: gameCoordinator)
            }
            
            self.gameCoordinator = gameCoordinator
            
        } else {
            
            // If no game coordinator was specified, try to retrieve it from the global OctopusKit environment. This may be the case if this view controller has been added to an ongoing game.
            
            guard   OctopusKit.initialized,
                    let octopusKitSingleton = OctopusKit.shared
            else {
                throw OKError.invalidConfiguration("OctopusKit.shared? singleton not initialized. OctopusKit(gameCoordinator:) must be called during application launch or OKViewController must be initialized with a OKGameCoordinator")
            }
        
            self.gameCoordinator = octopusKitSingleton.gameCoordinator
        }
        
        super.init(nibName: nil, bundle: nil)
        self.gameCoordinator?.viewController = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        if  let octopusKitSingleton = OctopusKit.shared {
            self.gameCoordinator = octopusKitSingleton.gameCoordinator
        } else {
            OctopusKit.logForWarnings("OctopusKit.shared? singleton not initialized. OctopusKit(gameCoordinator:) must be called at application launch. Ignore this warning if this OKViewController was loaded via AppKit/UIKit Storyboards.")
        }
        
        super.init(coder: aDecoder)
        self.gameCoordinator?.viewController = self
    }
        
    open override func viewDidLoad() {
        
        #if canImport(UIKit)
        OctopusKit.logForFramework("view.frame = \(self.view?.frame)")
        #elseif canImport(AppKit)
        OctopusKit.logForFramework("view.frame = \(self.view.frame)")
        #endif
        
        super.viewDidLoad()
        
        // To support SwiftUI, we create a child SKView using the root view's frame which will be provided by SwiftUI.
        
        // CHECK: Should the SKView be set up here or in `viewWillAppear`? Confirm which function is the earliest point where we can get the correct screen dimensions for creating the view with.
        
        if  let rootView = self.view as? SKView {
            self.spriteKitView = rootView
            
        } else {
            
            OctopusKit.logForFramework("Root view is nil or not an SpriteKit SKView — Creating child SKView")
            
            #if canImport(UIKit)
            guard let rootView = self.view else { fatalError("OKViewController has no root view!") }
            #elseif canImport(AppKit)
            let rootView = self.view
            #endif
            
            let childView = SKView(frame: rootView.frame)
            rootView.addSubview(childView)
            self.spriteKitView = childView
        }
        
        guard let spriteKitView = self.spriteKitView else { fatalError("OKViewController's spriteKitView is nil") }
        
        // Configure the view...
        
        // NOTE: CHECK: Configuring the view here as it may screw up the dimensions, according to http://www.ymc.ch/en/ios-7-sprite-kit-setting-up-correct-scene-dimensions — CHECK: Still relevant?
        
        spriteKitView.ignoresSiblingOrder = true // SpriteKit applies additional optimizations to improve rendering performance.
        
        //        spriteKitView.isMultipleTouchEnabled = ?
        //        audioEngine = OKAudioEngine()
        
        // If we are a new view controller being added to an ongoing game, such as when showing a new SwiftUI container view, present the ongoing scene.
        
        if  let ongoingScene = gameCoordinator?.currentScene {
            
            spriteKitView.presentScene(ongoingScene)
            ongoingScene.didUnpauseBySystem()
        
        } else {
            
            // ⚠️ BUG? NOTE: If we are the first view controller, present a blank placeholder scene to prevent a jarring white screen on launch, because that's what `SKView` seems to default to as of 2018-03, before `OKGameCoordinator` and its initial state prepares the first scene.
            
            spriteKitView.presentScene(SKScene(size: spriteKitView.frame.size))
        }
    }
    
    #if os(iOS) // MARK: - iOS
    
    /// Specifies whether the view controller prefers the status bar to be hidden or shown.
    ///
    /// This property allows other objects to dynamically override the associated read-only computed property of this view controller.
    open var prefersStatusBarHiddenOverride: Bool = true {
        didSet { self.setNeedsStatusBarAppearanceUpdate() }
    }
    
    open override var prefersStatusBarHidden: Bool {
        prefersStatusBarHiddenOverride
    }
    
    /// Specifies whether the system is allowed to hide the visual indicator for returning to the Home screen.
    ///
    /// This property allows other objects to dynamically override the associated read-only computed property of this view controller.
    ///
    /// - NOTE: The system takes your preference into account, but setting this property to `true` is no guarantee that the indicator will be hidden.
    open var prefersHomeIndicatorAutoHiddenOverride: Bool = true {
        didSet { self.setNeedsUpdateOfHomeIndicatorAutoHidden() }
    }
    
    open override var prefersHomeIndicatorAutoHidden: Bool {
        prefersHomeIndicatorAutoHiddenOverride
    }
    
    /// Specifies whether whether the view controller's contents should auto rotate.
    ///
    /// This property allows other objects to dynamically override the associated read-only computed property of this view controller.
    open var shouldAutorotateOverride: Bool = false
    
    open override var shouldAutorotate: Bool {
        shouldAutorotateOverride
    }
    
    /// Contains a dictionary of the interface orientations (rotations) that the view controller supports.
    ///
    /// This property allows other objects to dynamically override the read-only `supportedInterfaceOrientations` computed property of this view controller.
    open var supportedInterfaceOrientationsOverride: [UIUserInterfaceIdiom : UIInterfaceOrientationMask] = [
        .phone: .allButUpsideDown
    ]
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // If the `interfaceOrientations` dictionary does not contain a list of orientations for the current `userInterfaceIdiom`, return `all`.
        self.supportedInterfaceOrientationsOverride[UIDevice.current.userInterfaceIdiom] ?? .all
    }
    
    #endif

    #if os(iOS) || os(tvOS) // MARK: - iOS & tvOS
    
    open override func viewWillAppear(_ animated: Bool) {
        OctopusKit.logForFramework()
        super.viewWillAppear(animated)
        
        // NOTE: Do not call `enterInitialState()` from `viewWillAppear(_:)` as the OKScene's `createContents()` method may need access to the SKView's `safeAreaInsets`, which is [apparently] only set in `viewWillLayoutSubviews()` and may be necessary for positioning elements correctly on an iPhone X and other devices.
    }
    
    open override func viewWillLayoutSubviews() {
        OctopusKit.logForFramework()
        super.viewWillLayoutSubviews()

        // OBSOLETE?
        // NOTE: As the OKScene's `createContents()` method may need access to the SKView's `safeAreaInsets`, which is [apparently] only set in `viewWillLayoutSubviews()` and may be necessary for positioning elements correctly on an iPhone X and other devices, we should call `enterInitialState()` from here and not later from `viewWillAppear(_:)`.
        // CREDIT: http://www.ymc.ch/en/ios-7-sprite-kit-setting-up-correct-scene-dimensions
        // NOTE: Better yet, `enterInitialState()` from `OSAppDelegate.applicationDidBecomeActive(_:)`! :)
        // CHECK: Compare launch performance between calling `enterInitialState()` from `OSAppDelegate.applicationDidBecomeActive(_:)` versus `OKViewController.viewWillLayoutSubviews()`
    }
    
    open override func didReceiveMemoryWarning() {
        // Release any cached data, images, etc that aren't in use.
        OctopusKit.logForResources() // CHECK: Should the log be written to before freeing up some memory?
        super.didReceiveMemoryWarning()
        OctopusKit.clearAllCaches()
    }
    
    #endif

    #if os(OSX) // MARK: - macOS
    
    public private(set) var didSetupWindow = false
    
    public override func loadView() {
        // ℹ️ If you pass in nil for nibNameOrNil, nibName returns nil and loadView() throws an exception; in this case you must set view before view is invoked, or override loadView().
        // https://developer.apple.com/documentation/appkit/nsviewcontroller/1434481-init
        
        self.view = SKView()
    }
    
    open override func viewWillAppear() {
        OctopusKit.logForFramework()
        super.viewWillAppear()
        
        // NOTE: Do not call `enterInitialState()` from `viewWillAppear(_:)` as the OKScene's `createContents()` method may need access to the SKView's `safeAreaInsets`, which is [apparently] only set in `viewWillLayoutSubviews()` and may be necessary for positioning elements correctly on an iPhone X and other devices.
        
        #if canImport(AppKit)
        
        if !didSetupWindow {
            
            // TODO: Perform this at an earlier point in the application launch cycle, before the default Xcode project's menu is visible to the user.
            // CHECK: Should this be in loadView()?

            let window = self.view.window ?? NSApplication.shared.mainWindow
            
            window?.title = OctopusKit.shared.appName
            window?.tabbingMode = .disallowed // Disable window tabs (and the associated menu items).
            
            if  OctopusKit.configuration.modifyDefaultMenuBar {
                OKViewController.setDefaultMenus() // in OKViewController+Menus
            }
            
            didSetupWindow = true
        }
        
        #endif

    }
    
    open override func viewWillLayout() {
        OctopusKit.logForFramework()
        super.viewWillLayout()
        
        // OBSOLETE?
        // NOTE: As the OKScene's `createContents()` method may need access to the SKView's `safeAreaInsets`, which is [apparently] only set in `viewWillLayoutSubviews()` and may be necessary for positioning elements correctly on an iPhone X and other devices, we should call `enterInitialState()` from here and not later from `viewWillAppear(_:)`.
        // CREDIT: http://www.ymc.ch/en/ios-7-sprite-kit-setting-up-correct-scene-dimensions
        // NOTE: Better yet, `enterInitialState()` from `OSAppDelegate.applicationDidBecomeActive(_:)`! :)
        // CHECK: Compare launch performance between calling `enterInitialState()` from `OSAppDelegate.applicationDidBecomeActive(_:)` versus `OKViewController.viewWillLayoutSubviews()`
    }
    
    #endif
    
}
