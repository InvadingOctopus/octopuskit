/*
The MIT License (MIT)

Copyright (c) 2014 Justin Saunders

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

void main()
{
    // CREDIT: https://www.shadertoy.com/view/XdXXD4

    // distance from center of image, used to adjust blur
    vec2 uv = v_tex_coord; // / iResolution.xy;
    float d = length(uv - vec2(0.5, 0.5));
    
    // blur amount
    float blur = 0.0;
    blur = (1.0 + sin(u_time * 6.0)) * 0.5;
    blur *= 1.0 + sin(u_time * 16.0) * 0.5;
    blur = pow(blur, 3.0);
    blur *= 0.05;
    
    // reduce blur towards center
    blur *= d;
    
    // final color
    vec3 col;
    col.r = texture2D(u_texture, vec2(uv.x + blur, uv.y)).r;
    col.g = texture2D(u_texture, uv).g;
    col.b = texture2D(u_texture, vec2(uv.x - blur, uv.y)).b;
    
    // scanline
    float scanline = sin(uv.y * 800.0) * 0.04;
    col -= scanline;
    
    // vignette
    col *= 1.0 - d * 0.5;
    
    gl_FragColor = vec4(col, 1.0);
    //    gl_FragColor = vec4(1.0, 0, 0, 1.0);
}

