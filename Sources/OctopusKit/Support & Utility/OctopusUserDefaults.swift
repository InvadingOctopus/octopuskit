//
//  OctopusUserDefaults.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-10-31
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Review, improve and test
// TODO: Reevaluate according to official Swift API guidelines.

// GOAL:
// To be able to say `something = MyAppName.settings.someOption ?? default` and be provided a player preference or a default value, but that doesn't seem to be possible as of Swift 4. So, this file will just be a placeholder for some utility functions, for now.
// Also, this does not help with saving settings for each key. :(
// Specifying default in case of absence of preference key is preferable to do at the call site anyway, instead of a master store.

import Foundation

/// Represents a key and value pair saved in `UserDefaults.standard`, for storing player preferences and settings, as well as providing a default value if a key has not been saved.
///
/// If you prefer to manually specify a default value at every call site, make the type represented by this struct an `Optional` and supply a default value at the call site by chaining the `value` property with the `??` operator:
///
///     var setting = OctopusUserSetting<Int?>(key: "someKey", defaultValue: nil)
///     setting.value ?? 0
public struct OctopusUserSetting<Type>: CustomStringConvertible {
    
    // CHECK: Should this be named OctopusUserDefault for consistency with the rest of the API?
    
    public let key: String
    public let defaultValue: Type
    
    /// Sets the value for `key` in `UserDefaults.standard`, or gets the value if `key` exists in `UserDefaults.standard`, otherwise returns `defaultValue` (which may be `nil` for optionals.)
    public var value: Type {
        
        get {
            if let value = UserDefaults.standard.object(forKey: key) as? Type {
                OctopusKit.logForDebug.add("\"\(key)\" \(Type.self) = \(value)")
                return value
            }
            else {
                OctopusKit.logForDebug.add("\"\(key)\" \(Type.self) not found, defaultValue = \(defaultValue) ❗️")
                return defaultValue
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            // UserDefaults.standard.synchronize() // Not needed as of 2018-02? http://www.codingexplorer.com/nsuserdefaults-a-swift-introduction/
        }
    }
    
    public var description: String {
        return "UserDefault \"\(key)\" \(Type.self): \(value)"
    }
    
    /// Creates a representation of a user preference and registers the default value for the specified key in `UserDefaults.standard`.
    ///
    /// The preference may be retrieved by accessing the `value` property of this object, or any of the `UserDefaults.standard.object(forKey:)` series of functions.
    public init(key: String, defaultValue: Type) {
        self.key = key
        self.defaultValue = defaultValue
        
        // Register the default value to also make it accessible via any of the `UserDefaults.standard.object(forKey:)` series of functions.
        UserDefaults.standard.register(defaults: [key: defaultValue])
    }
}

public struct OctopusUserDefaults {
    
    @discardableResult public static func registerDefaultPreferencesFromPropertyList(named plistName: String = "UserDefaults") -> Bool {
        // NOTE: It seems best to call this from `NSApplicationDelegate.applicationWillFinishLaunching(_:)`, not `...DidFinishLaunching`, at least in an `NSDocument`-based app..
        // TODO: Proper error handling.
        OctopusKit.logForFramework.add()
        
        guard
            let path = Bundle.main.path(forResource: plistName, ofType: "plist"),
            let defaultsDictionary = NSDictionary(contentsOfFile: path) as? [String: Any] // TODO: Use idiomatic Swift 4
            else { return false }
        
        UserDefaults.standard.register(defaults: defaultsDictionary)
        return true
    }
    
    /// - Returns: The user default (preference) for `key` if `key` exists in `UserDefaults.standard` and is of type `T`, otherwise `nil`. Calling this function can be chained with the `??` operator to provide a default value.
    public static func preference<Type>(forKey key: String) -> Type? {
        if let value = UserDefaults.standard.object(forKey: key) as? Type {
            // let value = UserDefaults.standard.object(forKey: key) as? T {
            // let value = (UserDefaults.standard.dictionaryRepresentation())[key] as? T {
            OctopusKit.logForDebug.add("\"\(key)\" \(Type.self) = \(value)")
            return value
        }
        else {
            OctopusKit.logForDebug.add("\"\(key)\" \(Type.self) not found ❗️")
            return nil
        }
    }
    
}
