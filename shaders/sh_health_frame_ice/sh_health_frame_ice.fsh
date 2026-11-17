varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 frame = texture2D(gm_BaseTexture, v_vTexcoord);
    // Recolor the warm bronze highlights while retaining the dark metal and alpha.
    float bronze = smoothstep(0.02, 0.08, frame.r - frame.b);
    vec3 steelBlue = frame.r * vec3(0.48, 0.75, 1.0);
    gl_FragColor = v_vColour * vec4(mix(frame.rgb, steelBlue, bronze), frame.a);
}
