//
//  DictionaryComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/18.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// A component for storing a dictionary of arbitrary types and values. May be used for sharing data between other components.
///
/// If you need to share a lot of data or properties between components, consider writing a custom data component specific to your game.
public final class DictionaryComponent<KeyType: Hashable, ValueType>: OctopusComponent {
    
    public var dictionary: [KeyType: ValueType]
    
    /// Sets or returns the value for `key` from the dictionary.
    public subscript(key: KeyType) -> ValueType? {
        get { return dictionary[key] }
        set { dictionary[key] = newValue }
    }
    
    /// Creates a `DictionaryComponent` with an empty (non-`nil`) dictionary.
    public override init() {
        self.dictionary = [:]
        super.init()
    }
    
    /// Creates a `DictionaryComponent` and initializes it with the specified dictionary.
    public init(_ dictionary: [KeyType: ValueType]) {
        self.dictionary = dictionary
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

