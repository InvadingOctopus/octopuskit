//
//  SKAttributeValue+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/13.
//  ORIGINAL: SOURCE: https://github.com/twostraws/ShaderKit/blob/master/ShaderKitExtensions.swift
//  ORIGINAL: CREDIT: Copyright © 2019 Paul Hudson. Licensed under MIT License (see below)
//  UPDATES:  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// MIT License
//
// Copyright (c) 2019 Paul Hudson
// https://www.github.com/twostraws/ShaderKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SpriteKit

public extension SKAttributeValue {

    /// Creates and initializes a new attribute value object that converts a `CGSize` to a vector of two floating point numbers.
    ///
    /// - Parameters:
    ///   - size: The input size, i.e. the node's size. For an `SKTileMapNode` this is the `tileSize`.
    public convenience init(size: CGSize) {
        let size = vector_float2(Float(size.width),
                                 Float(size.height))
        self.init(vectorFloat2: size)
    }
}
