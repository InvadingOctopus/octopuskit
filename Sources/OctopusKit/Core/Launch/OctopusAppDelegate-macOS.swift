//
//  OctopusAppDelegate-macOS.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018-03-20
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Implement and verify pause/unpause

import SpriteKit
import CoreData

#if canImport(Cocoa)

/// The intermediary between the `NSApplication` provided by the operating system and your OctopusKit game.
///
/// - Important: Your project must have an `AppDelegate` class (prefixed by `@NSApplicationMain`) that inherits from `OctopusAppDelegate`, to serve as the launching point for your game.
///
/// Your `AppDelegate` should only implement `applicationWillLaunchOctopusKit()` as all other system events are handled by `OctopusAppDelegate`.
///
/// Your `applicationWillLaunchOctopusKit()` method must call `OctopusKit(appName:gameCoordinator:)` to initialize the `OctopusKit.shared` singleton instance, specifying a `OctopusGameCoordinator` or its subclass, with a list of `OctopusGameState`s and their associated scenes.
class OctopusAppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        OctopusKit.logForFramework.add()
        OctopusKit.verifyConfiguration()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // TODO: Allow game-specific code to intervene.
        return true
    }
    
    // MARK: - Pause/Unpause
    
    func applicationWillBecomeActive(_ notification: Notification) {
        OctopusKit.logForFramework.add()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        OctopusKit.logForFramework.add()
        
        // NOTE: Call `scene.applicationDidBecomeActive()` before `enterInitialState()` so we don't issue a superfluous unpause event to the very first scene of the game.
        
        // CHECK: Compare launch performance between calling `OctopusSceneController.enterInitialState()` from `OctopusAppDelegate.applicationDidBecomeActive(_:)`! versus `OctopusSceneController.viewWillLayoutSubviews()`
    }
    
    func applicationWillResignActive(_ notification: Notification) {
        OctopusKit.logForFramework.add()
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        OctopusKit.logForFramework.add()
    }
    
    /*
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        OctopusKit.logForFramework.add()
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    public lazy var persistentContainer: NSPersistentContainer = {
        
        guard let appName = OctopusKit.shared?.appName else {
            fatalError("OctopusKit.appName not set")
        }
        
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: appName)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    open func saveContext () {
        
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
     */
}

#endif
