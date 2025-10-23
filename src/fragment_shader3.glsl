#version 330

out vec4 FragColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define RECURSION_LIMIT 1000
#define PI 3.141592653589793238

// Method for the mathematical construction of the julia set
int juliaSet(vec2 c, vec2 constant) {
    int recursionCount;
    vec2 z = c;

    for (recursionCount = 0; recursionCount < RECURSION_LIMIT; recursionCount++) {
//      z = vec2( z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + constant;
//        z = vec2( z.x * z.x - z.y * z.y ,  ((u_mouse.x/u_resolution.x + 3.0) * 0.53) * z.x * z.y) + constant;
        float fi = atan(z.x/z.y);
        float d = sqrt(z.x * z.x + z.y * z.y );
        z = vec2(pow(d, u_mouse.x/u_resolution.x * 3.0) * cos(z.x * fi), pow(d, u_mouse.x/u_resolution.x * 3.0) * cos(z.x * fi)) + constant;

        if (length(z) > 0.5 + (u_mouse.y/u_resolution.y)) {
            break;
        }
    }

    return recursionCount;
}

void main() {
    vec2 mouse_norm = u_mouse / u_resolution;
    // Normalized pixel coordinates (-aspect to aspect, -1 to 1)
    vec2 uv = gl_FragCoord.xy / u_resolution;
    uv = (uv - 0.5) * 2.0;
    uv.x *= u_resolution.x / u_resolution.y; // aspect ratio

    vec2 uv2 = uv; // Copy for coloring
    vec3 col = vec3(1.0); // Base color

    // Julia set constants - cycle through them with time
    const vec2[7] constants = vec2[](
    vec2(-0.7176, -0.3842),
    vec2(-0.4, -0.59),
    vec2(0.34, -0.05),
    vec2(0.355, 0.355),
    vec2(-0.54, 0.54),
    vec2(0.355534, -0.337292),
    vec2(0.5, -0.5)
    );

//  int constantIndex = int(mod(u_time * 3.5, 6.0));
    vec2 juliaConstant = constants[0];

    // Rotation based on time
    float a = PI / 3.0 + u_time * 0.0 + PI/2; // Add time-based rotation
    vec2 U = vec2(cos(a), sin(a)); // U basis vector
    vec2 V = vec2(-U.y, U.x);      // V basis vector
    uv = vec2(dot(uv, U), dot(uv, V)); // Rotate UV
    uv *= 0.9;

    // Compute Julia set
    vec2 c = uv;
    int recursionCount = juliaSet(c, juliaConstant);
    float f = float(recursionCount) / float(RECURSION_LIMIT);

    // Color calculation
    float offset = 0.5;
    vec3 saturation = vec3(1.0, 1.0, 1.0);
    float totalSaturation = 0.3;
    float ff = pow(f, 1.0 - (f * 1.0));

    col.r = smoothstep(0.0, 1.0, ff) * (uv2.x * 0.5 + 0.3);
    col.b = smoothstep(0.0, 1.0, ff) * (uv2.y * 0.5 + 0.3);
    col.g = smoothstep(0.0, 1.0, ff) * (-uv2.x * 0.5 + 0.3);
    col.rgb *= 5000.0 * saturation * totalSaturation;

    // Mouse interaction - zoom
//    float zoom = 2 - smoothstep(0.0, 2.0, mouse_norm.y); // Mouse Y controls zoom (0.0 to 2.0)
    float zoom = 0.1;
    col.rgb *= zoom;

    FragColor = vec4(clamp(col.rgb, 0.0, 1.0), 1.0);
}