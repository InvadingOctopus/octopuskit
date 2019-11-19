//
//  OSSpecificViewModifiers.swift
//  OctopusUI
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/19.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  These OS-specific "view modifier modifiers" reduce code duplication in cases when you have a view that has multiple universal (OS-agnostic) view modifiers but 1 OS-specific view modifier, such as `.onCommand(_:perform:)` for macOS menus or `onPlayPauseCommand(perform:)` for the Apple TV Remote.
//
//  With these modifiers, you can avoid `#if os(...)` blocks or creating OS-specific copies of entire views:
//
//  Rectangle()
//      .padding() // For all systems.
//      .iOS   { $0.foregroundColor(.green) }
//      .macOS { $0.foregroundColor(.blue) }
//      .tvOSExcluded { $0.onTapGesture { self.dance() } } // tvOS doesn't have tap gestures.

import SwiftUI

public extension View {

    /// A wrapper for a view modifier that only applies on iOS/iPadOS.
    ///
    /// **Example**: `.iOS { $0.foregroundColor(.green) }`
    @inlinable
    func iOS <ModifiedViewType: View> (modifier: (Self) -> ModifiedViewType) -> some View {
        #if os(iOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    /// A wrapper for a view modifier that does **not** apply on iOS/iPadOS; only on macOS, tvOS and watchOS.
    ///
    /// **Example**: `.iOSExcluded { $0.foregroundColor(.red) }`
    @inlinable
    func iOSExcluded <ModifiedViewType: View> (modifier: (Self) -> ModifiedViewType) -> some View {
        #if !os(iOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    /// A wrapper for a view modifier that only applies on macOS.
    ///
    /// **Example**: `.macOS { $0.onCommand(save, perform: saveFile) }`
    @inlinable
    func macOS <ModifiedViewType: View> (modifier: (Self) -> ModifiedViewType) -> some View {
        #if os(macOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    /// A wrapper for a view modifier that does **not** apply on macOS; only on iOS/iPadOS, tvOS and watchOS.
    ///
    /// **Example**: `.macOSExcluded { $0.foregroundColor(.red) }`
    @inlinable
    func macOSExcluded <ModifiedViewType: View> (modifier: (Self) -> ModifiedViewType) -> some View {
        #if !os(macOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    /// A wrapper for a view modifier that only applies on tvOS.
    ///
    /// **Example**: `.tvOS { $0.focusable() }`
    @inlinable
    func tvOS <ModifiedViewType: View> (modifier: (Self) -> ModifiedViewType) -> some View {
        #if os(tvOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    /// A wrapper for a view modifier that does **not** apply on tvOS; only on iOS/iPadOS, macOS and watchOS.
    ///
    /// **Example**: `.tvOSExcluded { $0.foregroundColor(.red) }`
    @inlinable
    func tvOSExcluded <ModifiedViewType: View> (modifier: (Self) -> ModifiedViewType) -> some View {
        #if !os(tvOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    /// A wrapper for a view modifier that only applies on watchOS.
    ///
    /// **Example**: `.watchOS { $0.foregroundColor(.green) }`
    @inlinable
    func watchOS <ModifiedViewType: View> (modifier: (Self) -> ModifiedViewType) -> some View {
        #if os(watchOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    /// A wrapper for a view modifier that does **not** apply on watchOS; only on iOS/iPadOS, macOS and tvOS.
    ///
    /// **Example**: `.watchOSExcluded { $0.foregroundColor(.red) }`
    @inlinable
    func watchOSExcluded <ModifiedViewType: View> (modifier: (Self) -> ModifiedViewType) -> some View {
        #if !os(watchOS)
        return modifier(self)
        #else
        return self
        #endif
    }
}
