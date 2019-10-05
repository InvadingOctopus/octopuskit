//
//  SKShader+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import SpriteKit

/*
extension SKShader {
    
    /// If channels are not specified, the function will attempt to load them from files following the pattern "filename0.png" to "filename3.png" (they are required to be PNG files.)
    open class func shaderByUsingShadertoyUniforms(
        fileNamed: String,
        channel0: SKTexture? = nil,
        channel1: SKTexture? = nil,
        channel2: SKTexture? = nil,
        channel3: SKTexture? = nil)
        -> SKShader
    {
        /* Inputs set by Shadertoy.com:
        
        uniform vec3    iResolution;            // viewport resolution (in pixels)
        uniform float   iGlobalTime;            // shader playback time (in seconds)
        uniform float   iChannelTime[4];        // channel playback time (in seconds)
        uniform vec3    iChannelResolution[4];  // channel resolution (in pixels)
        uniform vec4    iMouse;                 // mouse pixel coords. xy: current (if MLB down), zw: click
        uniform samplerXX iChannel0..3;         // input channel. XX = 2D/Cube
        uniform vec4    iDate;                  // (year, month, day, time in seconds)
        uniform float   iSampleRate;            // sound sample rate (i.e., 44100)
        */
        
        /* Inputs set by Sprite Kit:
        
        sampler2D   u_texture;      // Uniform. A sampler associated with the texture used to render the node.
        float       u_time;         // Uniform. The elapsed time in the simulation.
        vec2        u_sprite_size;  // Uniform. The size of the sprite in pixels.
        float       u_path_length;  // Uniform. This uniform is provided only when the shader is attached to an SKShapeNode object’s strokeShader property. The total length of the path in points.
        vec2        v_tex_coord;    // Varying. The coordinates used to access the texture. These are normalized so that the point (0.0,0.0) is in the bottom-left corner of the texture.
        vec4        v_color_mix;    // Varying. The premultiplied color value for the node being rendered.
        float       v_path_distance;    // Varying. This varying is provided only when the shader is attached to an SKShapeNode object’s strokeShader property. The distance along the path in points.
        vec4        SKDefaultShading    // Function. A function that provides the default behavior used by Sprite Kit.
        */
        
        let shader = SKShader(fileNamed: fileNamed)
        let fileTitle = fileNamed.lastPathComponent.stringByDeletingPathExtension
        let channels: [SKTexture?] = [channel0, channel1, channel2, channel3]
        
        for index in 0...3 {
            var texture: SKTexture?
            
            if channels[index] != nil {
                texture = channels[index]
            } else if let path = NSBundle.mainBundle().pathForResource(fileTitle, ofType: "png") {
                texture = SKTexture(imageNamed: "\(fileTitle)\(index)")
            }
            
            if texture != nil {
                let textureUniform = SKUniform(name: "iChannel\(index)", texture: texture!)
                shader.uniforms += [textureUniform]
            }
        }
        
        return shader
    }
}
*/
