/* 
    Melon Shaders by June
    https://j0sh.cf
*/

#include "/lib/settings.glsl"
#include "/lib/util.glsl"

// FRAGMENT SHADER //

#ifdef FRAG

/* DRAWBUFFERS:04 */
layout (location = 0) out vec4 colorOut;
layout (location = 1) out vec4 bloomOut;

/*
const float centerDepthSmoothHalflife = 8.0;
*/

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;

uniform float viewWidth;
uniform float viewHeight;
uniform float centerDepthSmooth;

#include "/lib/poisson.glsl"

void main() {
    vec3 color = texture2D(colortex0, texcoord).rgb;

    #ifdef DOF
    float currentDepth = texture2D(depthtex0, texcoord).r;
    vec2 oneTexel = 1.0 / vec2(viewWidth, viewHeight);

    // distance blur
    if (currentDepth >= centerDepthSmooth+0.015) {
        vec3 blurred = vec3(0.0);
        for (int i = 0; i <= 32; i++) {
                vec2 offset = poissonDisk[i] * oneTexel * 12;
                blurred += texture2D(colortex0, texcoord + offset).rgb;
        }
        color = mix(color, blurred / 32.0, clamp((currentDepth-(centerDepthSmooth+0.015))*35.0, 0.0, 1.0));
    }
    
    // close up blur
    else if (currentDepth <= centerDepthSmooth) {
        vec3 blurred = vec3(0.0);
        for (int i = 0; i <= 32; i++) {
                vec2 offset = poissonDisk[i] * oneTexel * 12;
                blurred += texture2D(colortex0, texcoord + offset).rgb;
        }
        color = mix(color, blurred / 32.0, clamp((centerDepthSmooth-currentDepth)*35.0, 0.0, 1.0));
    }
    #endif

    #ifdef BLOOM
    // output bloom if pixel is bright enough
    int matMask = int(texture2D(colortex1, texcoord).a+0.5);
    vec3 bloomSample = vec3(0.0);
    if (luma(color) > 6.5 || (matMask == 4 && EMISSIVE_MAP != 0)) {
        bloomSample = color;
    }
    bloomOut = vec4(bloomSample, 1.0);
    #endif

    colorOut = vec4(color, 1.0);
}

#endif

// VERTEX SHADER //

#ifdef VERT

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif