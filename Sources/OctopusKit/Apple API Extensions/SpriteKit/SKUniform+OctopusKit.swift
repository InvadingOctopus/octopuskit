//
//  SKUniform+OctopusKit.swift
//  OctopusKit
//
//  Created by Paul Hudson https://github.com/twostraws
//  Original source at https://github.com/twostraws/ShaderKit/blob/master/ShaderKitExtensions.swift
//  Updated by ShinryakuTako@invadingoctopus.io on 2020/04/14.
//  Copyright © 2020 Invading Octopus and © 2019 Paul Hudson. Licensed under Apache License v2.0 (see LICENSE.txt) and MIT License (see below)
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

public extension SKUniform {
        
    /// Initializes a new uniform object that holds a vector of four floating-point numbers taken from the specified `SKColor`.
    ///
    /// - Parameters:
    ///   - name: The name used to identify the uniform variable; you use this name inside your shader to read the uniform variable’s value, e.g.: `u_color`.
    ///   - color: The color to create the initial vector from.
    convenience init(name: String, color: SKColor) {
        
        #if os(macOS)

        guard let colorInRGB = color.usingColorSpace(.deviceRGB) else {
            OctopusKit.logForErrors("Cannot convert \(color) to deviceRGB space.")
            self.init(name: name, vectorFloat4: vector_float4.zero)
            return
        }
        
        let colorComponents = vector_float4([Float(colorInRGB.redComponent),
                                             Float(colorInRGB.greenComponent),
                                             Float(colorInRGB.blueComponent),
                                             Float(colorInRGB.alphaComponent)])
        #else
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let colorComponents = vector_float4([Float(r), Float(g), Float(b), Float(a)])
        
        #endif

        self.init(name: name, vectorFloat4: colorComponents)
    }
    
    /// Initializes a new uniform object that holds a vector of two floating-point numbers taken from the specified `CGSize`.
    ///
    /// - Parameters:
    ///   - name: The name used to identify the uniform variable; you use this name inside your shader to read the uniform variable’s value, e.g.: `u_size`.
    ///   - size: The size to create the initial vector from.
    convenience init(name: String, size: CGSize) {
        let size = vector_float2(Float(size.width), Float(size.height))
        self.init(name: name, vectorFloat2: size)
    }
    
    /// Initializes a new uniform object that holds a vector of two floating-point numbers taken from the specified `CGPoint`.
    ///
    /// - Parameters:
    ///   - name: The name used to identify the uniform variable; you use this name inside your shader to read the uniform variable’s value, e.g.: `u_center`.
    ///   - point: The point to create the initial vector from.
    convenience init(name: String, point: CGPoint) {
        let point = vector_float2(Float(point.x), Float(point.y))
        self.init(name: name, vectorFloat2: point)
    }
}
