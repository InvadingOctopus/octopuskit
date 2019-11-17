//
//  KeyboardEventComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/17.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: A way to associate each stored input with the node that received it.
// CHECK: Use arrays of each event category?
// TODO: Improve performance by using `NSEvent.keyCode` instead of `NSEvent.characters?`?

import SpriteKit

#if canImport(AppKit)

/// Stores the keyboard input events received by a scene or interactive node to be used by other components on the next frame update.
///
/// Stores each event category for a single frame for other components to process, and clears it on the next frame unless new events of the same category are received.
///
/// - NOTE: The scene or node must forward the event data from its `keyDown(with:)` and related methods, to this component for it to function.
@available(macOS 10.15, *)
public final class KeyboardEventComponent: OctopusComponent, OctopusUpdatableComponent {
    
    // MARK: - Subtypes
    
    /// Not currently used.
    public enum KeyboardEventCategory {
        
        /// A `keyDown` event.
        case keyDown
        
        /// A `keyUp` event.
        case keyUp
        
        /// A `flagsChanged` event.
        case flagsChanged
    }
    
    /// Holds the data for a keyboard event as received by a scene or node.
    public final class KeyboardEvent: Equatable, CustomStringConvertible {
        
        // NOTE: `Equatable` conformance cannot be automatically synthesized by Swift 4.1 for classes.
        
        public let event: NSEvent
        public let node:  SKNode // CHECK: Should this be optional?
        
        public var shouldClear: Bool = false // Not private(set) so we can make update(deltaTime:) @inlinable
        
        @inlinable
        public var description: String {
            "\(event)"
        }
        
        public static func == (left: KeyboardEvent, right: KeyboardEvent) -> Bool {
            return (left.event === right.event
                &&  left.node  === right.node)
        }
        
        public init(event: NSEvent, node: SKNode) {
            self.event = event
            self.node  = node
        }
        
    }

    // MARK: - Properties
    
    // MARK: Events
        
    // NOTE: We use `NSEvent.charactersIgnoringModifiers` instead of `NSEvent.characters` because:
    // This property is set to the non-modifier key character pressed for dead keys, such as Option-e. For example, Option-e (no shift key) returns an “e" for this method, whereas the characters property returns an empty string.
    // `NSEvent.characters` is set to an empty string for dead keys, such as Option-e. However, for a key combination such as Option-Shift-e this property is set to the standard accent ("´").
    // https://developer.apple.com/documentation/appkit/nsevent/1524605-charactersignoringmodifiers
    // https://developer.apple.com/documentation/appkit/nsevent/1534183-characters
    
    @LogInputEventChanges(propertyName: "KeyboardEventComponent.keyDown")
    public var keyDown: KeyboardEvent? = nil {
        didSet {
            if  keyDown != oldValue,
                let charactersDown = keyDown?.event.charactersIgnoringModifiers
            {
                // Add the pressed keys to the relevant lists.
                self.charactersDownForCurrentFrame.formUnion(charactersDown)
                self.charactersPressed.formUnion(charactersDown)
                
                // Remove the pressed keys from the list of keys that were lifted.
                self.charactersUpForCurrentFrame.subtract(charactersDown)
            }
        }
    }
    
    @LogInputEventChanges(propertyName: "KeyboardEventComponent.keyUp")
    public var keyUp: KeyboardEvent? = nil {
        didSet {
            if  keyUp != oldValue,
                let charactersUp = keyUp?.event.charactersIgnoringModifiers
            {
                // Add the lifted keys to the `keysUpForCurrentFrame` list.
                self.charactersUpForCurrentFrame.formUnion(charactersUp)
                
                // Remove the lifted keys from the list of keys that were pressed.
                self.charactersDownForCurrentFrame.subtract(charactersUp)
                self.charactersPressed.subtract(charactersUp)
            }
        }
    }
    
    @LogInputEventChanges(propertyName: "KeyboardEventComponent.flagsChanged", omitOldValue: true)
    public var flagsChanged: KeyboardEvent? = nil
        
    /// Returns an array of all events for the current frame.
    ///
    /// - IMPORTANT: The array returned by this property is a *snapshot* of the events that are *currently* stored by this component; it does *not* automatically point to new events when they are received. To ensure that you have the latest events, either query the individual `key...` properties or recheck this property at the point of use.
    @inlinable
    public var allEvents: [KeyboardEvent?] {
        [keyDown,
         keyUp,
         flagsChanged]
    }
    
    // The `characters...` properties are not private(set) so we can make update(deltaTime:) @inlinable
    
    /// A set of the characters that were included in the `keyDown` events received in the current frame.
    ///
    /// - NOTE: This list ignores modifier keys except Shift. e.g. `Shift+2` will generate a `@` and `Shift+E` will generate an uppercase `E`, but `Option+E` will generate a lowercase `e`.
    public var charactersDownForCurrentFrame: Set<Character> = []
    
    /// A set of the characters that were included in the `keyUp` events received in the current frame.
    ///
    /// - NOTE: This list ignores modifier keys except Shift. e.g. `Shift+2` will generate a `@` and `Shift+E` will generate an uppercase `E`, but `Option+E` will generate a lowercase `e`.
    public var charactersUpForCurrentFrame: Set<Character> = []
    
    /// A set of the characters that were included in all `keyDown` events received so far but not in any `keyUp` events yet.
    ///
    /// Use this property to check which keys are still being pressed by the user.
    ///
    /// - NOTE: This list ignores modifier keys except Shift. e.g. `Shift+2` will generate a `@` and `Shift+E` will generate an uppercase `E`, but `Option+E` will generate a lowercase `e`.
    public var charactersPressed: Set<Character> = []
    
    // MARK: - Frame Cycle
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
  
        // #1: Discard all events if we are part of a scene that has displayed or dismissed a subscene in this frame.
        // CHECK: Necessary? Useful?
        
        if  let scene = coComponent(SpriteKitSceneComponent.self)?.scene,
            scene.didPresentSubsceneThisFrame || scene.didDismissSubsceneThisFrame
        {
            clearAllEvents()
            return
        }
        
        // #2: Clear stale events whose flags have been set.
        
        // ℹ️ We cannot use `if let` unwrapping as we need to modify the actual properties themselves, not their values.
        
        if keyDown?.shouldClear         ?? false { keyDown      = nil }
        if keyUp?.shouldClear           ?? false { keyUp        = nil }
        if flagsChanged?.shouldClear    ?? false { flagsChanged = nil }
        
        // #3: Clear key lists.
        // CHECK: PERFORMANCE: Should we be `keepingCapacity`?
        
        charactersDownForCurrentFrame.removeAll(keepingCapacity: true)
        charactersUpForCurrentFrame  .removeAll(keepingCapacity: true)
        
        // #4: Flag non-`nil` events to be cleared on the next frame, so that other components do not see any stale input data.
    
        keyDown?.shouldClear        = true
        keyUp?.shouldClear          = true
        flagsChanged?.shouldClear   = true
    }
    
    /// Discards all events.
    public func clearAllEvents() {
        
        // ℹ️ Since we have to set the properties themselves to `nil`, we cannot use an array etc. as that would only modify the array's members, not our properties. 2018-05-20
        
        keyDown         = nil
        keyUp           = nil
        flagsChanged    = nil
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        clearAllEvents()
    }
}

/// A placeholder protocol whose default implementation channels keyboard events from a SpriteKit node to the `KeyboardEventComponent` of the node's entity. Currently cannot be elegantly implemented because of the limitations and issues with Default Implementations and inheritance. 2018-05-08
@available(macOS 10.15, *)
@available(iOS, unavailable)
public protocol KeyboardEventProvider {
    func keyDown      (with event: NSEvent)
    func keyUp        (with event: NSEvent)
    func flagsChanged (with event: NSEvent)
}

#endif
    
#if !canImport(AppKit)
@available(iOS, unavailable)
public final class KeyboardEventComponent: macOSExclusiveComponent {}
#endif
