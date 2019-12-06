//
//  Codable+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/12/18.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CREDIT: https://twitter.com/johnsundell/status/1004290487799468032
// CREDIT: https://github.com/JohnSundell/SwiftTips

import Foundation

public extension Encodable {
    
    /// Attempts to returns the JSON `Data` representation of an `Encodable` type.
    @inlinable
    func encodedToJSON() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
}

public extension Data {
    
    /// Attempts to decode the `Data` as a JSON representation of a `Decodable` type, and returns the decoded instance if successful.
    ///
    /// If the type cannot be inferred then it must be manually specified, via the generic type parameter or casted via `as` or `as?`.
    @inlinable
    func decodedFromJSON<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
    
}
