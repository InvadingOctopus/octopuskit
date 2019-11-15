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

#if os(macOS)

/// The intermediary between the `NSApplication` provided by the operating system and your OctopusKit game.
///
/// - Important: Your project must have an `AppDelegate` class (prefixed by `@NSApplicationMain`) that inherits from `OctopusAppDelegate`, to serve as the launching point for your game.
///
/// Your `AppDelegate` should only implement `applicationWillLaunchOctopusKit()` as all other system events are handled by `OctopusAppDelegate`.
///
/// Your `applicationWillLaunchOctopusKit()` method must call `OctopusKit(appName:gameCoordinator:)` to initialize the `OctopusKit.shared` singleton instance, specifying a `OctopusGameCoordinator` or its subclass, with a list of `OctopusGameState`s and their associated scenes.
open class OctopusAppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    open func applicationDidFinishLaunching(_ aNotification: Notification) {
        OctopusKit.logForFramework.add()
        try! OctopusKit.verifyConfiguration()
    }
    
    open func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    open func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // TODO: Allow game-specific code to intervene.
        return true
    }
    
    // MARK: - Pause/Unpause
    
    open func applicationWillBecomeActive(_ notification: Notification) {
        OctopusKit.logForFramework.add()
    }
    
    open func applicationDidBecomeActive(_ notification: Notification) {
        OctopusKit.logForFramework.add()
        
        // NOTE: Call `scene.applicationDidBecomeActive()` before `enterInitialState()` so we don't issue a superfluous unpause event to the very first scene of the game.
        
        // CHECK: Compare launch performance between calling `OctopusViewController.enterInitialState()` from `OctopusAppDelegate.applicationDidBecomeActive(_:)`! versus `OctopusViewController.viewWillLayoutSubviews()`
    }
    
    open func applicationWillResignActive(_ notification: Notification) {
        OctopusKit.logForFramework.add()
    }
    
    open func applicationDidResignActive(_ notification: Notification) {
        OctopusKit.logForFramework.add()
    }
    
    // MARK: - Core Data stack

    open lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        
        guard let appName = OctopusKit.shared?.appName else {
            fatalError("OctopusKit.appName not set")
        }
        
        let container = NSPersistentContainer(name: appName)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
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
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction open func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    open func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        // BUG? When parameter is named `window` we get a warning:
        // Instance method 'windowWillReturnUndoManager(window:)' nearly matches optional requirement 'windowWillReturnUndoManager' of protocol 'NSWindowDelegate'
        
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    open func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        
        OctopusKit.logForFramework.add()
        
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        
        // If we got here, it is time to quit.
        return .terminateNow
    }
   
}

#endif
