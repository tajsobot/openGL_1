#version 330

out vec4 FragColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//SDFs:
float SDFsphere(vec3 pos, float r){
    return(length(pos) - r);
}

//final scene
float scene(vec3 pos) {
    float distance;
    distance = SDFsphere(pos, 1.0);
    return distance;
}

//RAYMARCHER:
#define MAX_STEPS 100
#define MAX_DIST 100.0
#define SURFACE_DIST 0.01

float raymarch(vec3 ro, vec3 rd) {
    float dO = 0.0;
    vec3 color = vec3(0.0);
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 pos = ro + rd * dO;
        float dS = scene(pos);
        dO += dS;
        if(dO > MAX_DIST || dS < SURFACE_DIST) {
            break;
        }
    }
    return dO;
}


vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.01, 0);
    vec3 n = scene(p) - vec3(
    scene(p-e.xyy),
    scene(p-e.yxy),
    scene(p-e.yyx)
    );

    return normalize(n);
}


void main() {
    //coord setup
    vec2 uv = gl_FragCoord.xy / u_resolution;
    uv += -0.5;
    uv.x *= u_resolution.x / u_resolution.y; // aspect ratio
    vec2 mouse_norm = u_mouse/u_resolution;

    vec3 color = vec3(0.0);

    vec3 ro = vec3(0.0 + (mouse_norm.x -0.5)*4, 0.0 + (mouse_norm.y -0.5)*4, 5.0);
    vec3 rd = normalize(vec3(uv, - 1.0));
    float d = raymarch(ro, rd);
    vec3 p = ro + rd * d;


    vec3 lightPosition = vec3(3.0 * sin(u_time*10.0),3.0 * sin(u_time* 3.2),3.0 * cos(u_time*10.0));

    if(d<MAX_DIST) {
        vec3 normal = getNormal(p);
        vec3 lightDirection = normalize(lightPosition - p);

        float diffuse = max(dot(normal, lightDirection), 0.1);
        color = vec3(1.0, 1.0, 1.0) * diffuse;
    }
    else color = vec3(uv.xy, 1.0);

    FragColor = vec4(color , 1.0);
}
