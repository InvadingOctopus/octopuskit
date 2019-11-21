// CREDIT: http://endlesswavesoftware.com/blog/spritekit-shaders/ from ShaderToy.com

/// - Attributes:
/// - a_time_factor_y: Value to multiply `u_time` with. Lower = slower. Default: 0.04
/// - a_time_factor_x: Value to multiply `u_time` with. Lower = slower. Default: 0.07
void main()
{
    vec2 uv = v_tex_coord;
    
    uv.y += (cos((uv.y + (u_time * a_time_factor_y)) * 45.0) * 0.0019) +
    (cos((uv.y + (u_time * 0.1)) * 10.0) * 0.002);
    
    uv.x += (sin((uv.y + (u_time * a_time_factor_x)) * 15.0) * 0.0029) +
    (sin((uv.y + (u_time * 0.1)) * 15.0) * 0.002);
    
    gl_FragColor = texture2D(u_texture, uv);
}
