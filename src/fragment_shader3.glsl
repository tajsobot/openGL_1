#version 330

out vec4 FragColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform vec2 u_rat;


/*0.128479, 0.595751
*/
#define RECURSION_LIMIT 1000
#define PI 3.141592653589793238

int binomial(int n, int k) {
    if (k < 0 || k > n) return 0;
    if (k == 0 || k == n) return 1;
    int res = 1;
    for (int i = 1; i <= k; i++) {
        res = res * (n - (k - i)) / i;
    }
    return res;
}
vec2 imaginaryPower(vec2 susy,float retar){
    vec2 box = vec2(0,0);
    for(float i=0;i<retar;i++){
        float temp=pow(box.x,retar-i)*pow(box.y,i);
        // float C=binomial( retar, i);
        float C=float(binomial(int(retar),int(i)));
        // box+=vec2((i%2)*temp,((i+1)%2)*temp)
        /*switch (val) {
            case 0.0://CANCER I HAJT IT
            box.x+=C*temp;
            break;
            case 1.0:
            box.y+=C*temp;
            break;
            case 2.0:
            box.x-=C*temp;
            break;
            case 3.0:
            box.y-=C*temp;
            break;
        }*/
    }
    return box;
}

// Method for the mathematical construction of the julia set
int juliaSet(vec2 c, vec2 constant) {
    int recursionCount;
    vec2 z = c;

    for (recursionCount = 0; recursionCount < RECURSION_LIMIT; recursionCount++) {
     //z =vec2( z.x * z.x - z.y * z.y, 2.0 * z.x * z.y)+vec2(u_rat.x,u_rat.y)+ (u_mouse/u_resolution-vec2(0.5,0.5))*2.0;

        z = vec2(
        z.x*z.x*z.x*z.x*z.x*z.x - 15.0*z.x*z.x*z.x*z.x*z.y*z.y
        + 15.0*z.x*z.x*z.y*z.y*z.y*z.y - z.y*z.y*z.y*z.y*z.y*z.y,
        6.0*z.x*z.x*z.x*z.x*z.x*z.y - 20.0*z.x*z.x*z.x*z.y*z.y*z.y
        + 6.0*z.x*z.y*z.y*z.y*z.y*z.y
        )+c+ (u_mouse/u_resolution-vec2(0.5,0.5))*2;//susy
       // z = vec2( pow(z.x,3)-3*z.x*pow(z.y,2) ,3*pow(z.x,2)*z.y-pow(z.y,3) )+c + (u_mouse/u_resolution-vec2(0.5,0.5))*2.0;
     //  z = vec2( pow(z.x,4)-6*z.pow(z.x,2)*pow(z.y,2)+pow(z.y,4) ,(4*pow(z.x,3)*z.y-4*pow(z.y,3)*z.x) )+c + (u_mouse/u_resolution-vec2(0.5,0.5))*2.0;



        //        z = vec2( z.x * z.x - z.y * z.y ,  ((u_mouse.x/u_resolution.x + 3.0) * 0.53) * z.x * z.y) + constant;
      //  float fi = atan(z.x/z.y);
       // float d = sqrt(z.x * z.x + z.y * z.y );
        //z = vec2(pow(d, u_mouse.x/u_resolution.x * 3.0) * cos(z.x * fi), pow(d, u_mouse.x/u_resolution.x * 3.0) * cos(z.x * fi)) + constant;
        //z= imaginaryPower(z,2) + (u_mouse/u_resolution-vec2(0.5,0.5))*2.0;

        if (length(z) > 3.0) {
            break;
        }
    }

    return recursionCount;
}

void main() {
    vec2 mouse_norm = u_mouse / u_resolution;
    // Normalized pixel coordinates (-aspect to aspect, -1 to 1)
    vec2 uv = gl_FragCoord.xy / u_resolution;
    uv = (uv - 0.5/*-0.3*vec2(sin(u_time),cos(2*u_time))*/)*2/* *  exp(sin(5*u_time))*/;
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
 //   uv = vec2(dot(uv, U), dot(uv, V)); // Rotate UV
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
    float zoom = 0.001;
    col.rgb *= zoom;

    FragColor = vec4(clamp(col.rgb, 0.0, 1.0), 1.0);
}
/*
int fuck(int n) {
    int result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }
    return result;
}*/

/*}vec2 imaginaryPowerRec(vec2 susy,int pow){

    return ;
}*/