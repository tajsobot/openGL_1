#version 330 core

out vec4 FragColor; // Output color
uniform vec2 u_resolution; // Screen resolution
uniform float u_time;

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution; // Normalize screen coordinates [0, 1]

    // Set up tiling
    float tileSize = (1/u_time)/100; // Size of each tile
    vec2 tileUV = mod(uv, tileSize) / tileSize; // UV coordinates within a single tile

    // Circle properties
    vec2 circleCenter = vec2(0.5, 0.5); // Center of the circle in tile space
    float radius = 0.5; // Radius of the circle

    // Distance from the circle center
    float dist = length(tileUV - circleCenter);

    // Determine color based on whether the fragment is inside the circle
    if (dist < radius) {
        FragColor = vec4(1.0, 0.0, 0.0, 1.0); // Red color for the circle
    } else {
        FragColor = vec4(0.0, 0.0, 0.0, 1.0); // Black color for the background
    }
}
