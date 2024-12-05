#version 130

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;  // Canvas size (width, height)
uniform vec2 u_mouse;       // Mouse position in screen pixels
uniform float u_time;       // Time in seconds since load

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution;
    vec2 mouseNorm = u_mouse/u_resolution;
    float pct = 0.0;

    pct = distance(st,vec2(0.5));
    vec3 color = vec3(mod(pct, mouseNorm.x), mod(pct, mouseNorm.y),  0.5);

    gl_FragColor = vec4(color, 0.1);

}
