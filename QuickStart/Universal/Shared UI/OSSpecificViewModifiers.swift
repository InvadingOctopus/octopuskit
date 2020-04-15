//
//  OSSpecificViewModifiers.swift
//  OctopusUI
//  https://github.com/InvadingOctopus/octopusui
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/19.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)

// ❕ This code has been copied from the OctopusUI package to simplify the OctopusKit QuickStart tutorial and to keep OctopusKit self-contained (without dependencies on other packages). It may be an older version than its counterpart in OctopusUI.
// ❗️ Exclude this file from your project if you import OctopusUI, otherwise using one of these extensions will cause an ambiguity conflict and prevent compilation.

import SwiftUI

public extension View {

    // These OS-specific "view modifier modifiers" or "view modifier wrappers" reduce code duplication in cases when you have a view that has many universal (OS-agnostic) view modifiers but one or few OS-specific view modifiers.
    //
    // With these wrappers, you can avoid creating OS-specific copies of entire views just to use some OS-specific modifiers:
    //
    // Rectangle()
    //      .padding() // For all systems.
    //      .iOS   { $0.foregroundColor(.green) }
    //      .macOS { $0.foregroundColor(.blue) }
    //      .tvOSExcluded { focusable(false) }
    //
    // ⚠️ NOTE: You will still get compile-time errors if you try to use APIs that are unavailable on other platforms, such as `.onCommand(_:perform:)` which is only on macOS menus or `onPlayPauseCommand(perform:)` which is only on tvOS.
    
    // TODO: GOAL: To be able to write this like:
    // .iOS(foregroundColor(.green))
    // but that's apparently not possible in Swift at the moment :(
    // https://forums.swift.org/t/swiftui-extension-for-os-specific-view-modifiers-that-seems-too-arcane-to-implement/30897
        
    // MARK: - iOS/iPadOS
    
    /// A wrapper for a view modifier that only applies on iOS/iPadOS.
    ///
    /// **Example**: `.iOS { $0.foregroundColor(.green) }`
    ///
    /// - IMPORTANT: Using OS-specific APIs which may be unavailable on other platforms may cause compile-time errors.
    @inlinable
    func iOS <ModifiedView: View> (modifier: (Self) -> ModifiedView) -> some View {
        #if os(iOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    /// A wrapper for a view modifier that does **not** apply on iOS/iPadOS; only on macOS, tvOS and watchOS.
    ///
    /// **Example**: `.iOSExcluded { $0.foregroundColor(.red) }`
    ///
    /// - IMPORTANT: Using OS-specific APIs which may be unavailable on other platforms may cause compile-time errors.
    @inlinable
    func iOSExcluded <ModifiedView: View> (modifier: (Self) -> ModifiedView) -> some View {
        #if !os(iOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    // MARK: - macOS
    
    /// A wrapper for a view modifier that only applies on macOS.
    ///
    /// **Example**: `.macOS { $0.foregroundColor(.green) }`
    ///
    /// - IMPORTANT: Using OS-specific APIs which may be unavailable on other platforms may cause compile-time errors.
    @inlinable
    func macOS <ModifiedView: View> (modifier: (Self) -> ModifiedView) -> some View {
        #if os(macOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    /// A wrapper for a view modifier that does **not** apply on macOS; only on iOS/iPadOS, tvOS and watchOS.
    ///
    /// **Example**: `.macOSExcluded { $0.foregroundColor(.red) }`
    ///
    /// - IMPORTANT: Using OS-specific APIs which may be unavailable on other platforms may cause compile-time errors.
    @inlinable
    func macOSExcluded <ModifiedView: View> (modifier: (Self) -> ModifiedView) -> some View {
        #if !os(macOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    // MARK: - tvOS
    
    /// A wrapper for a view modifier that only applies on tvOS.
    ///
    /// **Example**: `.tvOS { $0.foregroundColor(.green) }`
    ///
    /// - IMPORTANT: Using OS-specific APIs which may be unavailable on other platforms may cause compile-time errors.
    @inlinable
    func tvOS <ModifiedView: View> (modifier: (Self) -> ModifiedView) -> some View {
        #if os(tvOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    /// A wrapper for a view modifier that does **not** apply on tvOS; only on iOS/iPadOS, macOS and watchOS.
    ///
    /// **Example**: `.tvOSExcluded { $0.foregroundColor(.red) }`
    ///
    /// - IMPORTANT: Using OS-specific APIs which may be unavailable on other platforms may cause compile-time errors.
    @inlinable
    func tvOSExcluded <ModifiedView: View> (modifier: (Self) -> ModifiedView) -> some View {
        #if !os(tvOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    // MARK: - watchOS
    
    /// A wrapper for a view modifier that only applies on watchOS.
    ///
    /// **Example**: `.watchOS { $0.foregroundColor(.green) }`
    ///
    /// - IMPORTANT: Using OS-specific APIs which may be unavailable on other platforms may cause compile-time errors.
    @inlinable
    func watchOS <ModifiedView: View> (modifier: (Self) -> ModifiedView) -> some View {
        #if os(watchOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    /// A wrapper for a view modifier that does **not** apply on watchOS; only on iOS/iPadOS, macOS and tvOS.
    ///
    /// **Example**: `.watchOSExcluded { $0.foregroundColor(.red) }`
    ///
    /// - IMPORTANT: Using OS-specific APIs which may be unavailable on other platforms may cause compile-time errors.
    @inlinable
    func watchOSExcluded <ModifiedView: View> (modifier: (Self) -> ModifiedView) -> some View {
        #if !os(watchOS)
        return modifier(self)
        #else
        return self
        #endif
    }
}
