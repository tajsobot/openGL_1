#version 330

out vec4 FragColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    uv.x *= u_resolution.x / u_resolution.y;
    vec2 mouse_norm = u_mouse/u_resolution;

    float t = u_time;
    float animT = sin(u_time);
    float drawTime = floor(u_time * 20);

    float r = mix(3.5, 5.0, uv.x);  // prve dve sta zacetni in koncni r, tretja je "interpolacijska tocka" med vrednostima, ta je na x osi
    r = mix(3.5, mouse_norm.x*5, uv.x); //odkomentiraj za kontrolo z misko
    float x = uv.y;
    x = 0.1; //zacetni x
    for (int i = 0; i < drawTime * 2; i++) {
        x = r * x * (1.0 - x);
        if (i > drawTime) {
            if (abs(x - uv.y) < 0.001) {
                FragColor = vec4(1.0, 0.0, 0.0, 1.0);
                return;
            }
        }
    }
    FragColor = vec4(1.0, 1.0, 1.0, 1.0); // background
}
