//
//  NSMenu+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/03/31.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

#if canImport(AppKit)

import AppKit

public extension NSMenu {
    
    /// Removes the first menu item matching the specified title from the menu.
    func removeItem(withTitle title: String) {
        if  let itemToRemove = self.item(withTitle: title) {
            self.removeItem(itemToRemove)
        }
    }
    
    /// Removes the first menu item matching the specified tag from the menu.
    func removeItem(withTag tag: Int) {
        if  let itemToRemove = self.item(withTag: tag) {
            self.removeItem(itemToRemove)
        }
    }
}

#endif
