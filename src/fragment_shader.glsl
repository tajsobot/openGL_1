#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;  // Canvas size (width, height)
uniform vec2 u_mouse;       // Mouse position in screen pixels
uniform float u_time;       // Time in seconds since load

void main() {
    vec2 fragCoordNorm = gl_FragCoord.xy / u_resolution;
    vec2 mouseNorm = u_mouse / u_resolution;
    vec2 circleCenter = mouseNorm;
    float radius = 0.1;
    if (distance(fragCoordNorm, circleCenter) < pow(radius, 3.0*length(mouseNorm - vec2(0.5,0.5))) ) {
        gl_FragColor = vec4(mouseNorm.x, mouseNorm.y, 0.5, 1.0);
    } else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
}
