
void main()
{
    // TODO: Sprite size
    vec2 uv = v_tex_coord;
    
    if (mod(uv.y, 2) == 0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
    else {
        gl_FragColor = texture2D(u_texture, uv);
    }
}
