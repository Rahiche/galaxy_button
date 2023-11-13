#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>
uniform vec2 iResolution;
uniform float iTime;

#define NUM_LAYERS 2.0
#define M_PI acos(-1.0)
#define M_TAU M_PI*2.0

vec2
rotate(vec2 a, float b)
{
    float c = cos(b);
    float s = sin(b);
    return vec2(
    a.x * c - a.y * s,
    a.x * s + a.y * c
    );
}

float makeStar(vec2 uv, float flare)
{
    float d = length(uv);
    float star = .5/d;
    float m = star;


    float rays = max(1.0 - abs(uv.x*uv.y * 0.0), 0.0);
    m +=rays * flare;

    uv = rotate(uv, M_PI/ 4.0);
    rays = max(1.0 - abs(uv.x*uv.y * 0.0), 0.0);
    m +=rays*flare *0.3;

    m *= smoothstep(1.0, .2, d);

    return m;
}

float hash21(vec2 p)
{
    p = fract(p*vec2(123.34, 456.21));
    p += dot(p, p+45.32);
    return fract(p.x*p.y);
}


// Define the colors array with the given RGB values
const vec3 color1 = vec3(59.0, 28.0, 70.0) / 255.0;
const vec3 color2 = vec3(59.0, 28.0, 70.0) / 255.0;
const vec3 color3 = vec3(132.0, 74.0, 106.0) / 255.0;
const vec3 color4 = vec3(102.0, 53.0, 148.0) / 255.0;
const vec3 color5 = vec3(102.0, 53.0, 148.0) / 255.0;
const vec3 color6 = vec3(73.0, 37.0, 103.0) / 255.0;
const vec3 color7 = vec3(151.0, 79.0, 208.0) / 255.0;
const vec3 color8 = vec3(89.0, 43.0, 65.0) / 255.0;

vec3 getColorFromIndex(float n) {
    // Map the value of n to the range [0, 8)
    int index = int(fract(n * 2345.2) * 8.0);

    // Manually return a color based on the index
    if (index == 0) return color1;
    if (index == 1) return color2;
    if (index == 2) return color3;
    if (index == 3) return color4;
    if (index == 4) return color5;
    if (index == 5) return color6;
    if (index == 6) return color7;
    if (index == 7) return color8;

    // Default color if needed
    return color1;
}

vec3 StarLayer(vec2 uv)
{
    vec3 col = vec3(0.0);
    vec2 id = floor(uv);
    vec2 gv = fract(uv) - 0.5;





    for(int y = -1; y <= 1; ++y)
    for(int x = -1; x <= 1; ++x)
    {
        vec2 offset = vec2(x, y);
        float n = hash21(id + offset);
        float size = fract(n*345.45);

        float flare = smoothstep(.9, 1.0, size)* 0.9;
        float star = makeStar(gv - offset - vec2(n, fract(n*34.0) ) + .5, flare);

        // Use the hash to pick a color from the predefined set
        int colorIndex = int(fract(n*2345.2) * 8.0);
        vec3 color = getColorFromIndex(n);

        // will make it shine
        star *= sin(2.0 + n*M_TAU)*.5 +1.;
        col += star*size*color;
    }

    return col;
}


out vec4 fragColor;

void main()
{
    vec2 fragPosition = FlutterFragCoord();

    vec2 uv  = ((fragPosition) - 0.5*iResolution.xy)/iResolution.y;

    vec3 col = vec3(0.0);
    float t = iTime*.004;

    for(float i = 0.0;i < 1.0; i += 1.0/NUM_LAYERS)
    {
        float depth = fract(i +t);

        float scale = mix(10.0, 0.5, depth);

        float fade = depth*smoothstep(1., .9, depth);

        float size = 1.6;

        col += StarLayer(uv*scale + i*453.2)*fade;
        scale = mix(10.0, 0.5, fract(i + 1.0*t));
    }
    fragColor = vec4(col, 1.0);
}