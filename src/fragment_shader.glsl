#version 330 core

out vec4 FragColor; // Output color
uniform vec2 u_resolution; // Resolution of the window
uniform float u_time; // Time variable for animation (optional)

vec3 mandelbrot(vec2 c) {
    const int maxIterations = 100;
    vec2 z = vec2(0.0, 0.0);
    int iterations = 0;

    for (int i = 0; i < maxIterations; i++) {
        float x = z.x * z.x - z.y * z.y + c.x;  // Re(z^2 + c)
        float y = 2.0 * z.x * z.y + c.y;        // Im(z^2 + c)
        z = vec2(x, y);

        // If the magnitude of z exceeds 2, it has escaped
        if (length(z) > 10000.0) {
            break;
        }

        iterations++;
    }

    // Return the color based on the number of iterations
    float norm = float(iterations) / float(maxIterations);
    return vec3(norm, norm * 0.5, norm * 0.5); // Color gradient based on iterations
}

void main()
{
    // Convert pixel coordinates to normalized [-1, 1] coordinates
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    uv = uv * 2.0 - 1.0;

    // Scale and shift to adjust the view window (zoom and position)
    vec2 c = uv * 2.0 - vec2(0.5, 0.0); // Set the zoom level and position

    // Calculate the Mandelbrot value
    vec3 color = mandelbrot(c);

    // Output the final color
    FragColor = vec4(color, 1.0);
}
