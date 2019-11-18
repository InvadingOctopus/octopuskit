//
//  TypeSafeIdentifiers.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/11.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// A protocol for reliably storing and passing around strings or other primitive types as identifiers, that would otherwise be vulnerable to typos and other mistakes.
///
/// Similar to `Notification.Name` in Foundation.
///
/// To use, create a `struct` that only provides a `rawValue` property and its type, because Swift will synthesize the default initializer and `Hashable` conformance, and the default implementation for `TypeSafeIdentifiers` provides the convenience initializer and `CustomStringConvertible` `description`.
///
/// To add identifiers and access them conveniently, create an `extension` for the adopting `struct` and add identifiers as `static` instances of the adopting `struct`.
///
/// **Example**
///
///     struct TextureName: TypeSafeIdentifiers {
///         let rawValue: String
///     }
///
///     extension TextureName {
///         static let player = TextureName("PlayerShip")
///         static let enemy  = TextureName("BaddieShip")
///     }
///
///     player.texture = SKTexture(imageNamed: TextureName.player.rawValue)
///     enemy.texture  = MyCustomType(name: TextureName.enemy)
public protocol TypeSafeIdentifiers: Hashable, RawRepresentable, CustomStringConvertible {
    
    associatedtype RawValueType
    
    var rawValue: RawValueType { get } // A conforming type only needs to provide this property.
    
    init(_ rawValue: RawValueType) // This is provided by the default implementation extension.
    init(rawValue: RawValueType) // This is synthesized by Swift (for structs).
}

public extension TypeSafeIdentifiers {
    
    // ☺️ Thanks to this default implementation and the synthesis of default initializers for structs by awesome Swift, an struct conforming to `TypeSafeIdentifiers` only needs to provide a `rawValue` property and its type.
    
    init(_ rawValue: RawValueType) { self.init(rawValue: rawValue) }
    
    var description: String { "\(rawValue)" }
}

