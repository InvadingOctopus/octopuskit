void main()
{
    vec2 uv = v_tex_coord; // / iResolution.xy;
    gl_FragColor = vec4(uv,abs(cos(u_Time *0.5)) + sin( u_Time * uv.x / abs(sin(3.0 * uv.y / u_Time * sin(3.5)))) *sin(u_Time),1.0);
}
