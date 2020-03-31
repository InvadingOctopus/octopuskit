//
//  OKViewController+Menus.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/03/31.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

#if canImport(AppKit)

import AppKit

// MARK: macOS Default Menus

extension OKViewController {
    
    /// Add menu items common to all games.
    ///
    /// This is done programmatically as a convenience to avoid manual Storyboard modification for new projects.
    open class func setDefaultMenus() {
        
        // TODO: Add pause/unpause
        // TODO: Internationalization (handle menu names in different languages).
        // CHECK: Replace with NIB/Storyboard when we can add resources to Swift packages?
        
        guard let mainMenu = NSApplication.shared.mainMenu else { return }
        
        // #1: Rename the File menu because we don't got no stinkin' files here :)
        
        if  let fileMenu = mainMenu.item(withTitle: "File"),
            let fileSubmenu = fileMenu.submenu
        {
            let gameMenuTitle = "Game"
            fileMenu.title = gameMenuTitle
            fileSubmenu.title = gameMenuTitle
            
            // Remove menu items that [usually] don't belong in a game.
            
            fileSubmenu.removeItem(withTitle: "Close")
            fileSubmenu.removeItem(withTitle: "Page Setup…")
            fileSubmenu.removeItem(withTitle: "Print…")
        }
        
        // #2: Remove the Format menu as well.
        
        if  let formatMenu = mainMenu.item(withTitle: "Format") {
            mainMenu.removeItem(formatMenu)
        }
        
        // #3: Add some basic View options.
        
        if  let viewSubmenu = mainMenu.item(withTitle: "View")?.submenu {
//            let fpsMenuItem = NSMenuItem()
//            fpsMenuItem.title = "Toggle FPS"
//            //fpsMenuItem.target = self // CHECK: Omit to resolve via the responder chain?
//            fpsMenuItem.action = #selector(toggleShowFPS)
            
            viewSubmenu.addItem(NSMenuItem(title: "Toggle FPS",
                                           action: #selector(toggleFPS(_:)),
                                           keyEquivalent: ""))
            
            // Remove unnecessary View menu items.
            // Tab-related menus are disabled via `NSWindow.tabbingMode` in `OKViewController.viewWillAppear()`
            
            viewSubmenu.removeItem(withTitle: "Show Tab Bar")
            viewSubmenu.removeItem(withTitle: "Show All Tabs")
        }
        
        // #4: Add a Debug menu.
        
        let debugMenuItem   = NSMenuItem()
        let debugSubmenu    = NSMenu(title: "Debug")
        debugMenuItem.title = "Debug"
        
        // Insert the Debug menu before the Window menu, or as the third-last menu.
        
        let helpMenuIndex   = mainMenu.indexOfItem(withTitle: "Window")
        let debugMenuIndex  = helpMenuIndex >= 0 ? helpMenuIndex : mainMenu.items.endIndex - 3
        
        mainMenu.setSubmenu(debugSubmenu, for: debugMenuItem)
        mainMenu.insertItem(debugMenuItem, at: debugMenuIndex)
        
        // Add the Debug menu items.
        
        debugSubmenu.addItem(NSMenuItem(title: "Toggle All",
                                        action: #selector(toggleAll(_:)),
                                        keyEquivalent: ""))
        
        debugSubmenu.addItem(NSMenuItem(title: "Toggle Draw Count",
                                        action: #selector(toggleDrawCount(_:)),
                                        keyEquivalent: ""))
        
        debugSubmenu.addItem(NSMenuItem(title: "Toggle Fields",
                                        action: #selector(toggleFields(_:)),
                                        keyEquivalent: ""))
        
        debugSubmenu.addItem(NSMenuItem(title: "Toggle Node Count",
                                        action: #selector(toggleNodeCount(_:)),
                                        keyEquivalent: ""))
        
        debugSubmenu.addItem(NSMenuItem(title: "Toggle Physics",
                                        action: #selector(togglePhysics(_:)),
                                        keyEquivalent: ""))
        
        debugSubmenu.addItem(NSMenuItem(title: "Toggle Quad Count",
                                        action: #selector(toggleQuadCount(_:)),
                                        keyEquivalent: ""))
    }
    
    // MARK: - Actions
    
    @objc open func toggleAll(_ sender: NSMenuItem) {
        toggleDrawCount(sender)
        toggleFields(sender)
        toggleFPS(sender)
        toggleNodeCount(sender)
        togglePhysics(sender)
        toggleQuadCount(sender)
    }
    
    @objc open func toggleDrawCount(_ sender: NSMenuItem) {
        self.spriteKitView?.showsDrawCount.toggle()
    }
    
    @objc open func toggleFields(_ sender: NSMenuItem) {
        self.spriteKitView?.showsFields.toggle()
    }
    
    @objc open func toggleFPS(_ sender: NSMenuItem) {
        self.spriteKitView?.showsFPS.toggle()
    }
    
    @objc open func toggleNodeCount(_ sender: NSMenuItem) {
        self.spriteKitView?.showsNodeCount.toggle()
    }
    
    @objc open func togglePhysics(_ sender: NSMenuItem) {
        self.spriteKitView?.showsPhysics.toggle()
    }
    
    @objc open func toggleQuadCount(_ sender: NSMenuItem) {
        self.spriteKitView?.showsQuadCount.toggle()
    }
}

#endif
