//
//  OctopusViewController.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/24.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
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
/// - Important: The view controller of your main SpriteKit view must be an `OctopusSpriteKitViewController` or its subclass, for the OctopusKit to function.
open class OctopusViewController: OSViewController {
    
    public unowned var gameController: OctopusGameController? {
        didSet {
            // Display the new game controller's current scene.
            if oldValue !== gameController {
                // TODO
            }
        }
    }
    
    public fileprivate(set) var spriteKitView: SKView?
    
    // MARK: - Life Cycle
    
    public required init(gameController: OctopusGameController? = nil) {
        
        // To support easy SwiftUI usage...
        
        if let gameController = gameController {
            
            if  let existingGameController = OctopusKit.shared?.gameController {
                fatalError("OctopusKit already initialized with \(existingGameController) — OctopusViewController initialized with \(gameController)")
            }
            
            OctopusKit(gameController: gameController)
            self.gameController = gameController
            
        } else {
            
            guard   OctopusKit.initialized,
                    let octopusKitSingleton = OctopusKit.shared
            else {
                fatalError("OctopusKit.shared? singleton not initialized. OctopusKit(gameController:) must be called at application launch.")
            }
        
            self.gameController = octopusKitSingleton.gameController
        }
        
        super.init(nibName: nil, bundle: nil)
        self.gameController?.viewController = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        if  let octopusKitSingleton = OctopusKit.shared {
            self.gameController = octopusKitSingleton.gameController
        } else {
            OctopusKit.logForWarnings.add("OctopusKit.shared? singleton not initialized. OctopusKit(gameController:) must be called at application launch. Ignore this warning if this OctopusViewController was loaded via Interface Builder.")
        }
        
        super.init(coder: aDecoder)
        self.gameController?.viewController = self
    }
    
//    open override func loadView() {
//        OctopusKit.logForFramework.add("\(preferredContentSize)")
//
//        // ℹ️ APPLE: Your custom implementation of this method should not call super.
//        // https://developer.apple.com/documentation/uikit/uiviewcontroller/1621454-loadview
//
//        self.view = SKView()
//    }
    
    open override func viewDidLoad() {
        OctopusKit.logForFramework.add("view.frame = \(String(optional: self.view?.frame))")
        super.viewDidLoad()
        
        // To support SwiftUI, we create a child SKView using the root view's frame which will be provided by SwiftUI.
        
        // CHECK: Should the SKView be set up here or in viewWillAppear? Confirm which function is the earliest point where we can get the correct screen dimensions for creating the view with.
        
        if let rootView = self.view as? SKView {
            self.spriteKitView = rootView
            
        } else {
            
            OctopusKit.logForFramework.add("Root view is nil or not an SpriteKit SKView — Creating child SKView")
            
            guard let rootView = self.view else { fatalError("OctopusSceneController has no root view!") }
            
            let childView = SKView(frame: rootView.frame)
            rootView.addSubview(childView)
            self.spriteKitView = childView
        }
        
        guard let spriteKitView = self.spriteKitView else { fatalError("OctopusSceneController's spriteKitView is nil") }
        
        // Configure the view...
        
        // NOTE: CHECK: Configuring the view here as it may screw up the dimensions, according to http://www.ymc.ch/en/ios-7-sprite-kit-setting-up-correct-scene-dimensions — CHECK: Still relevant?
        
        spriteKitView.ignoresSiblingOrder = true // SpriteKit applies additional optimizations to improve rendering performance.
        
        //        spriteKitView.isMultipleTouchEnabled = ?
        //        audioEngine = OctopusAudioEngine()
        
        // ⚠️ NOTE: Create a blank placeholder scene to prevent a jarring white screen on launch, because that's what `SKView` seems to default to as of 2018-03, until `OctopusGameController` and its initial state prepares the first scene prepare and presents its contents.
        
        spriteKitView.presentScene(SKScene(size: spriteKitView.frame.size))
    }
    
    #if os(iOS)
    // MARK: iOS-Specific
    
    /// Specifies whether the scene controller prefers the status bar to be hidden or shown.
    ///
    /// This property allows other objects to dynamically override the associated read-only computed property of this scene controller.
    open var prefersStatusBarHiddenOverride: Bool = true {
        didSet { self.setNeedsStatusBarAppearanceUpdate() }
    }
    
    open override var prefersStatusBarHidden: Bool {
        return prefersStatusBarHiddenOverride
    }
    
    /// Specifies whether the system is allowed to hide the visual indicator for returning to the Home screen.
    ///
    /// This property allows other objects to dynamically override the associated read-only computed property of this scene controller.
    ///
    /// - NOTE: The system takes your preference into account, but setting this property to `true` is no guarantee that the indicator will be hidden.
    open var prefersHomeIndicatorAutoHiddenOverride: Bool = true {
        didSet { self.setNeedsUpdateOfHomeIndicatorAutoHidden() }
    }
    
    open override var prefersHomeIndicatorAutoHidden: Bool {
        return prefersHomeIndicatorAutoHiddenOverride
    }
    
    /// Specifies whether whether the scene controller's contents should auto rotate.
    ///
    /// This property allows other objects to dynamically override the associated read-only computed property of this scene controller.
    open var shouldAutorotateOverride: Bool = false
    
    open override var shouldAutorotate: Bool {
        return shouldAutorotateOverride
    }
    
    /// Contains a dictionary of the interface orientations (rotations) that the scene controller supports.
    ///
    /// This property allows other objects to dynamically override the read-only `supportedInterfaceOrientations` computed property of this scene controller.
    open var supportedInterfaceOrientationsOverride: [UIUserInterfaceIdiom : UIInterfaceOrientationMask] = [
        .phone: .allButUpsideDown
    ]
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // If the `interfaceOrientations` dictionary does not contain a list of orientations for the current `userInterfaceIdiom`, return `all`.
        return self.supportedInterfaceOrientationsOverride[UIDevice.current.userInterfaceIdiom] ?? .all
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        OctopusKit.logForFramework.add()
        super.viewWillAppear(animated)
        
        // NOTE: Do not call `enterInitialState()` from `viewWillAppear(_:)` as the OctopusScene's `prepareContents()` method may need access to the SKView's `safeAreaInsets`, which is [apparently] only set in `viewWillLayoutSubviews()` and may be necessary for positioning elements correctly on an iPhone X and other devices.
    }
    
    open override func viewWillLayoutSubviews() {
        OctopusKit.logForFramework.add()
        super.viewWillLayoutSubviews()

        // OBSOLETE?
        // NOTE: As the OctopusScene's `prepareContents()` method may need access to the SKView's `safeAreaInsets`, which is [apparently] only set in `viewWillLayoutSubviews()` and may be necessary for positioning elements correctly on an iPhone X and other devices, we should call `enterInitialState()` from here and not later from `viewWillAppear(_:)`.
        // CREDIT: http://www.ymc.ch/en/ios-7-sprite-kit-setting-up-correct-scene-dimensions
        // NOTE: Better yet, `enterInitialState()` from `OctopusAppDelegate.applicationDidBecomeActive(_:)`! :)
        // CHECK: Compare launch performance between calling `enterInitialState()` from `OctopusAppDelegate.applicationDidBecomeActive(_:)` versus `OctopusSceneController.viewWillLayoutSubviews()`
    }
    
    open override func didReceiveMemoryWarning() {
        // Release any cached data, images, etc that aren't in use.
        OctopusKit.logForResources.add() // CHECK: Should the log be written to before freeing up some memory?
        super.didReceiveMemoryWarning()
        OctopusKit.clearAllCaches()
    }
    
    #elseif os(OSX)
    
    // MARK: macOS-specific
    
    open override func viewWillAppear() {
        OctopusKit.logForFramework.add()
        super.viewWillAppear()
        
        // NOTE: Do not call `enterInitialState()` from `viewWillAppear(_:)` as the OctopusScene's `prepareContents()` method may need access to the SKView's `safeAreaInsets`, which is [apparently] only set in `viewWillLayoutSubviews()` and may be necessary for positioning elements correctly on an iPhone X and other devices.
    }
    
    open override func viewWillLayout() {
        OctopusKit.logForFramework.add()
        super.viewWillLayout()
        
        // OBSOLETE?
        // NOTE: As the OctopusScene's `prepareContents()` method may need access to the SKView's `safeAreaInsets`, which is [apparently] only set in `viewWillLayoutSubviews()` and may be necessary for positioning elements correctly on an iPhone X and other devices, we should call `enterInitialState()` from here and not later from `viewWillAppear(_:)`.
        // CREDIT: http://www.ymc.ch/en/ios-7-sprite-kit-setting-up-correct-scene-dimensions
        // NOTE: Better yet, `enterInitialState()` from `OctopusAppDelegate.applicationDidBecomeActive(_:)`! :)
        // CHECK: Compare launch performance between calling `enterInitialState()` from `OctopusAppDelegate.applicationDidBecomeActive(_:)` versus `OctopusSceneController.viewWillLayoutSubviews()`
    }
    
    #endif
    
}


