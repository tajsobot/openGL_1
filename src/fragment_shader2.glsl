#version 330 core

out vec4 FragColor;

uniform vec2 iResolution; // Screen resolution
uniform float iTime;      // Animation time

// SDF for a sphere
float sphereSDF(vec3 p, float radius) {
    return length(p) - radius;
}

// SDF for a plane
float planeSDF(vec3 p, vec3 normal, float height) {
    return dot(p, normal) + height;
}

// Combine scene SDFs
float sceneSDF(vec3 p) {
    float sphere = sphereSDF(p - vec3(0.0, 0.5, 3.0), 1.0);
    float plane = planeSDF(p, vec3(0.0, 1.0, 0.0), 0.0);
    return min(sphere, plane); // Union of sphere and plane
}

// Raymarching function
float raymarch(vec3 ro, vec3 rd) {
    float t = 0.0;
    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;
        float d = sceneSDF(p);
        if (d < 0.001) return t; // Hit
        if (t > 50.0) break;     // Exceeded max distance
        t += d;
    }
    return -1.0; // No hit
}

// Calculate surface normal using SDF gradients
vec3 calcNormal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
    sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
    sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
    sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
    ));
}

// Basic lighting
vec3 lighting(vec3 p, vec3 ro, vec3 rd) {
    vec3 lightPos = vec3(2.0, 4.0, 2.0);
    vec3 normal = calcNormal(p);
    vec3 lightDir = normalize(lightPos - p);
    float diffuse = max(dot(normal, lightDir), 0.0);
    vec3 viewDir = normalize(ro - p);
    vec3 reflectDir = reflect(-lightDir, normal);
    float specular = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
    return vec3(0.2) + vec3(1.0) * diffuse + vec3(1.0) * specular;
}

// Perform raymarching for a single sample
vec3 sampleA(vec3 ro, vec3 rd) {
    float t = raymarch(ro, rd);
    if (t > 0.0) {
        vec3 p = ro + rd * t;
        return lighting(p, ro, rd);
    }
    return vec3(0.0); // Background color
}

void main() {
    vec2 uv = (gl_FragCoord.xy / iResolution) * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;

    // Ray origin and direction
    vec3 ro = vec3(0.0, 1.0, -5.0);
    vec3 baseDir = normalize(vec3(uv, 1.0));

    // Sub-pixel offsets for 4 samples
    vec2 offsets[4] = vec2[](
    vec2(-0.25, -0.25),
    vec2(0.25, -0.25),
    vec2(-0.25, 0.25),
    vec2(0.25, 0.25)
    );

    // Average color
    vec3 color = vec3(0.0);
    for (int i = 0; i < 4; i++) {
        vec2 jitter = offsets[i] / iResolution; // Sub-pixel jitter
        vec3 rd = normalize(vec3(uv + jitter, 1.0)); // Adjusted ray direction
        color += sampleA(ro, rd);
}
color /= 4.0; // Average the samples

FragColor = vec4(color, 1.0);
}
