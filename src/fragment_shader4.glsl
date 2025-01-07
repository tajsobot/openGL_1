#version 330

out vec4 FragColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    uv.x *= u_resolution.x / u_resolution.y;
    vec2 mouse_norm = u_mouse / u_resolution;

    float t = u_time;
    float animT = sin(u_time);
    float drawTime = min(1000, floor(u_time * 20));

    float r_start = 3.5;
    float r_end = 5.0;

    int subpixels = 5; // 2 -> 2x2 = 4 subpixli
    float subpixel_step = 1.0 / float(subpixels);
    vec3 color_sum = vec3(0.0);

    for (int i = 0; i < subpixels; i++) {
        for (int j = 0; j < subpixels; j++) { //dva loopa za subpixle
            vec2 sub_uv = uv;
            sub_uv.x += float(i) * subpixel_step / u_resolution.x;
            sub_uv.y += float(j) * subpixel_step / u_resolution.y;

            float r = mix(r_start, r_end, sub_uv.x);
            r = mix(mouse_norm.y*5, mouse_norm.x * 5.0, sub_uv.x); // odkomentiraj za kontrolo miske

            float x = sub_uv.y; //zacetna vrednost lahko tudi druga

            for (int k = 0; k < int(drawTime) * 2; k++) { //loop za biferkacijski diagram
                x = r * x * (1.0 - x);
                if (k > int(drawTime)) {
                    if (abs(x - sub_uv.y) < 0.001) {
                        color_sum += vec3(1.0, 0.0, 0.0); // Red for points in the bifurcation diagram
                        break;
                    }
                }
            }
        }
    }
    //povprecje pixlov
    color_sum /= float(subpixels * subpixels);
    FragColor = vec4(color_sum, 1.0);
}
