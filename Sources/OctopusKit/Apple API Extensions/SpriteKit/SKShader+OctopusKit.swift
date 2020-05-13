//
//  SKShader+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import SpriteKit

public extension SKShader {
    
    /// Creates a new shader object by loading the source for a fragment shader from a file stored in the app’s bundle, and initializes it with the specified uniform data and attributes list, if any. Also logs shader compilation failures.
    ///
    /// - Parameters:
    ///   - name:       The name of the fragment shader to load. The file must be present in your app bundle with the same name and a .fsh file extension.
    ///   - uniforms:   A list of uniforms to add to the shader object. May be `nil`.
    ///   - attributes: A list of attributes to add to the shader object. May be `nil`.
    convenience init(sourceFromFileNamed name: String,
                     uniforms:      [SKUniform]?   = nil,
                     attributes:    [SKAttribute]? = nil)
    {
        // ℹ️ https://developer.apple.com/library/archive/technotes/tn2451/_index.html#//apple_ref/doc/uid/DTS40017609-CH1-SHADERCOMPILATION
        // Note that error handling is encapsulated when using SKShader's convenience initializer init(fileNamed:) (see the signature comments in SKShader.h). To enable compilation failure logging, use SKShader(source:uniforms:) instead.
        
        // CHECK: PERFORMANCE: Should we use `SKShader.init(fileNamed:)` or `SKShader.init(source: String, uniforms: [SKUniform])`?
    
        guard let path = Bundle.main.path(forResource: name, ofType: "fsh") else {
            OctopusKit.logForErrors("\(name).fsh not found in bundle")
            fatalError()
        }
        
        guard let source = try? String(contentsOfFile: path, encoding: .utf8) else {
            OctopusKit.logForErrors("Cannot load \(name).fsh as String")
            fatalError()
        }
        
        if  let uniforms = uniforms {
            self.init(source: source, uniforms: uniforms)
        } else {
            self.init(source: source)
        }
        
        // self.init(fileNamed: name)
        // self.uniforms = uniforms   ?? []
        
        self.attributes = attributes ?? []
    }
     
    /// Adds an attribute if an identically-named attribute is not already present.
    ///
    /// - Returns: `true` if the attribute was added.
    @discardableResult
    func addAttributeIfNotPresent(name: String, type: SKAttributeType) -> Bool {
        if !self.attributes.contains(where: { $0.name == name }) {
            // Append instead of assigning to avoid wiping existing attributes.
            self.attributes += [SKAttribute(name: name,  type: type)]
            return true
        } else {
            return false
        }
    }
    
    /// Add attributes, skipping those with names matching attributes which are already present.
    ///
    /// - Parameter dictionary: A dictionary where the keys are attribute names, and the values are the `SKAttributeType`.
    func addAttributesIfNotPresent(_ dictionary: [String : SKAttributeType]) {
        dictionary.forEach { self.addAttributeIfNotPresent(name: $0.key, type: $0.value) }
    }
    
}
 
extension SKShader {
            
    /// Initializes a shader with a set of texture uniforms to match ShaderToy.com inputs.
    ///
    /// If channels are not specified, this function will attempt to load them from the application bundle by matching the pattern `"filename0.png"` to `"filename3.png"`.
    open class func withShadertoyUniforms(
        fileNamed name: String,
        channel0: SKTexture? = nil,
        channel1: SKTexture? = nil,
        channel2: SKTexture? = nil,
        channel3: SKTexture? = nil)
        -> SKShader
    {
        /* Data provided by ShaderToy.com:
         
         vec3        iResolution             image/buffer        The viewport resolution (z is pixel aspect ratio, usually 1.0)
         float       iTime                   image/sound/buffer  Current time in seconds
         float       iTimeDelta              image/buffer        Time it takes to render a frame, in seconds
         int         iFrame                  image/buffer        Current frame
         float       iFrameRate              image/buffer        Number of frames rendered per second
         float       iChannelTime[4]         image/buffer        Time for channel (if video or sound), in seconds
         vec3        iChannelResolution[4]   image/buffer/sound  Input texture resolution for each channel
         vec4        iMouse                  image/buffer        xy = current pixel coords (if LMB is down). zw = click pixel
         sampler2D   iChannel{i}             image/buffer/sound  Sampler for input textures i
         vec4        iDate                   image/buffer/sound  Year, month, day, time in seconds in .xyzw
         float       iSampleRate             image/buffer/sound  The sound sample rate (typically 44100)
         */
        
        /* Data provided by SpriteKit:
         
         sampler2D   u_texture;         // Uniform. A sampler associated with the texture used to render the node.
         float       u_time;            // Uniform. The elapsed time in the simulation.
         float       u_path_length;     // Uniform. Provided only when the shader is attached to an SKShapeNode object’s strokeShader property. This value represents the total length of the path, in points.
         vec2        v_tex_coord;       // Varying. The coordinates used to access the texture. These coordinates are normalized so that the point (0.0,0.0) is in the bottom-left corner of the texture.
         vec4        v_color_mix;       // Varying. The premultiplied color value for the node being rendered.
         float       v_path_distance;   // Varying. Provided only when the shader is attached to an SKShapeNode object’s strokeShader property. This value represents the distance along the path in points.
         vec4        SKDefaultShading   // Function. A function that provides the default behavior used by SpriteKit.
         
         vec2        u_sprite_size;     // Uniform. The size of the sprite in pixels. Availability uncertain?
         */
        
        let shader      = SKShader(fileNamed: name)
        let shaderTitle = URL(fileURLWithPath: name).deletingPathExtension().lastPathComponent
        
        let channels: [SKTexture?] = [channel0, channel1, channel2, channel3]
        
        for index in 0...3 {
            var texture: SKTexture?
            
            if  channels[index] != nil {
                texture = channels[index]
            } else if Bundle.main.path(forResource: shaderTitle, ofType: "png") != nil {
                texture = SKTexture(imageNamed: "\(shaderTitle)\(index)")
            }
            
            if  let texture = texture {
                let textureUniform = SKUniform(name: "iChannel\(index)", texture: texture)
                shader.uniforms += [textureUniform]
            }
        }
        
        return shader
    }
}

