#include <chrono>
#include <iostream>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <string>
#include <fstream>
#include <sstream>
#include <thread> // For simulating a game loop
#include <windows.h> // Required for the following declaration


//naPORNo

// Function to read a file's content
std::string readShaderFile(const std::string& filepath) {
    std::ifstream file(filepath);
    if (!file.is_open()) {
        std::cerr << "ERROR: Unable to open shader file: " << filepath << std::endl;
        return "";
    }
    std::stringstream buffer;
    buffer << file.rdbuf();
    return buffer.str();
}

// Function to compile a shader
unsigned int compileShader(unsigned int type, const std::string& source) {
    unsigned int shader = glCreateShader(type);
    const char* src = source.c_str();
    glShaderSource(shader, 1, &src, nullptr);
    glCompileShader(shader);

    // Check for compilation errors
    int success;
    char infoLog[512];
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(shader, 512, nullptr, infoLog);
        std::cerr << "ERROR: Shader Compilation Failed\n" << infoLog << std::endl;
    }
    return shader;
}

// Function to create a shader program
unsigned int createShaderProgram(const std::string& vertexSource, const std::string& fragmentSource) {
    unsigned int vertexShader = compileShader(GL_VERTEX_SHADER, vertexSource);
    unsigned int fragmentShader = compileShader(GL_FRAGMENT_SHADER, fragmentSource);

    unsigned int shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);

    // Check for linking errors
    int success;
    char infoLog[512];
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
    if (!success) {
        glGetProgramInfoLog(shaderProgram, 512, nullptr, infoLog);
        std::cerr << "ERROR: Program Linking Failed\n" << infoLog << std::endl;
    }

    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    return shaderProgram;
}

// Global variables for mouse position
double mouseX = 0.0, mouseY = 0.0;

// GLFW callback to track mouse movement
void mouse_callback(GLFWwindow* window, double xpos, double ypos) {
    mouseX = xpos;
    mouseY = ypos;
}


extern "C" {
    __attribute__((dllexport)) DWORD NvOptimusEnablement = 0x00000001; // NVIDIA GPUs
}


int main() {
    // Initialize GLFW
    if (!glfwInit()) {
        std::cerr << "ERROR: GLFW Initialization Failed\n";
        return -1;
    }
    // Set GLFW window hints for OpenGL version and profile
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    float width = 1200.0f, height = 900.0f;

    // Create a windowed OpenGL context
    GLFWwindow* window = glfwCreateWindow(width, height, "OpenGL Shader Example", nullptr, nullptr);
    if (!window) {
        std::cerr << "ERROR: GLFW Window Creation Failed\n";
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);
    glfwSwapInterval(100); // Disable V-Sync

    // Load OpenGL functions with GLAD
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        std::cerr << "ERROR: GLAD Initialization Failed\n";
        glfwTerminate();
        return -1;
    }

    // Set up mouse callback
    glfwSetCursorPosCallback(window, mouse_callback);

    // Load shaders
    // std::string fragmentShaderSource = readShaderFile(R"(..\src\my_marcher.glsl)");
    std::string fragmentShaderSource = readShaderFile(R"(..\src\my_marcher.glsl)");
    std::string vertexShaderSource = readShaderFile(R"(..\src\vertex_shader.glsl)");

    if (fragmentShaderSource.empty() || vertexShaderSource.empty()) {
        std::cerr << "ERROR: Shader source is empty. Check file paths!" << std::endl;
        glfwTerminate();
        return -1;
    }

    unsigned int shaderProgram = createShaderProgram(vertexShaderSource, fragmentShaderSource);

    // Set up the VAO and VBO for a full-screen quad
    float vertices[] = {
        // Positions (x, y)    // Texture Coordinates (u, v)
        -1.0f, -1.0f,          0.0f, 0.0f, // Bottom-left
         1.0f, -1.0f,          1.0f, 0.0f, // Bottom-right
         1.0f,  1.0f,          1.0f, 1.0f, // Top-right
        -1.0f,  1.0f,          0.0f, 1.0f  // Top-left
    };
    unsigned int indices[] = {
        0, 1, 2, // First triangle
        2, 3, 0  // Second triangle
    };

    unsigned int VAO, VBO, EBO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glGenBuffers(1, &EBO);

    // Bind and set up VAO
    glBindVertexArray(VAO);

    // Bind and fill the VBO
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    // Bind and fill the EBO
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    // Define the vertex attribute pointers
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), static_cast<void *>(nullptr)); // Position attribute
    glEnableVertexAttribArray(0);

    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), (void*)(2 * sizeof(float))); // Texture coordinate attribute
    glEnableVertexAttribArray(1);

    // Unbind the VAO
    glBindVertexArray(1);

    float time1 = 0.0f;

    using Clock = std::chrono::high_resolution_clock;
    auto previousTime = Clock::now();

    float deltaTime = 0.0f;

    // Main loop
    while (!glfwWindowShouldClose(window)) {
        auto currentTime = Clock::now();
        deltaTime = std::chrono::duration<float>(currentTime - previousTime).count();
        previousTime = currentTime;

        glClear(GL_COLOR_BUFFER_BIT);

        glUseProgram(shaderProgram);

        // Pass uniforms
        glUniform1f(glGetUniformLocation(shaderProgram, "u_time"), time1);
        glUniform2f(glGetUniformLocation(shaderProgram, "u_resolution"), width, height);
        glUniform2f(glGetUniformLocation(shaderProgram, "u_mouse"), mouseX, height - mouseY); // Flip Y-axis

        glBindVertexArray(VAO);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr);

        glfwSwapBuffers(window);
        glfwPollEvents();

        std::cout << deltaTime*1000 <<" ms" << std::endl;

        time1 += 0.1 * deltaTime; // Increment time for animation
    }

    // Clean up
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteBuffers(1, &EBO);
    glDeleteProgram(shaderProgram);

    glfwTerminate();
    return 0;
}
