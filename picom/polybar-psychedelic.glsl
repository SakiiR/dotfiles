#version 330

in vec2 texcoord;
uniform sampler2D tex;
uniform float time;

ivec2 window_size = textureSize(tex, 0);

vec4 default_post_processing(vec4 c);

float PI = 3.1415926535;
float TWO_PI = 6.2831853070;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float opacity_threshold(float opacity) {
    float max_opacity = 0.99;
    if (opacity >= max_opacity) return 1.0;
    else return min(1.0, opacity / max_opacity);
}

vec4 anim(float p) {
    vec2 uv = texcoord / vec2(window_size);

    // --- Idle drift: slow pixel shimmer using time ---
    float idle = p; // 1.0 when fully locked
    float drift_speed = 0.005;
    float pixel_size = 1.2;
    vec2 pixel_cell = floor(texcoord / pixel_size);
    float pixel_rand = random(pixel_cell);

    // Slow continuous horizontal drift per pixel block
    float drift_amount = sin(time * drift_speed + pixel_rand * TWO_PI) * 0.5 + 0.8;
    float drift_offset = (drift_amount - 0.5) * pixel_size * 0.8 * idle;

    // Occasional stronger glitch burst (every ~5s)
    float burst_time = floor(time / 5.0);
    float burst_rand = random(vec2(burst_time, pixel_rand));
    float burst = step(0.97, burst_rand) * (1.0 - fract(time / 5.0) * 3.0);
    burst = max(0.0, burst);
    drift_offset += burst * pixel_size * 3.0 * (random(vec2(pixel_rand, burst_time)) - 0.5);

    vec2 drifted_coord = clamp(texcoord + vec2(drift_offset, 0.0), vec2(0.0), vec2(window_size) - vec2(1.0));

    // --- Open animation: pixel dissolve ---
    float appear_threshold = pixel_rand;
    float pixel_alpha = smoothstep(appear_threshold - 0.05, appear_threshold + 0.05, p);

    // --- Chromatic aberration: subtle idle pulse + strong on open ---
    float ca_idle = sin(time * 0.3 + pixel_rand * PI) * 0.002 * window_size.x * idle;
    float ca_open = (1.0 - p) * 0.006 * window_size.x;
    float ca = ca_idle + ca_open;

    vec2 r_coord = clamp(drifted_coord + vec2(ca, 0.0),  vec2(0.0), vec2(window_size) - vec2(1.0));
    vec2 b_coord = clamp(drifted_coord - vec2(ca, 0.0),  vec2(0.0), vec2(window_size) - vec2(1.0));

    vec4 col;
    col.r = texelFetch(tex, ivec2(r_coord), 0).r;
    col.g = texelFetch(tex, ivec2(drifted_coord), 0).g;
    col.b = texelFetch(tex, ivec2(b_coord), 0).b;
    col.a = texelFetch(tex, ivec2(drifted_coord), 0).a;

    // --- Scanline darkening ---
    float scanline = 0.85 + 0.15 * sin(uv.y * window_size.y * PI);
    scanline = mix(1.0, scanline, (1.0 - p) * 2.0 + idle * 0.3);
    col.rgb *= scanline;

    // --- Slow rolling scanline while idle ---
    float roll_line = sin(uv.y * 40.0 - time * 0.5) * 0.5 + 0.5;
    float roll_strength = 0.04 * idle;
    col.rgb *= 1.0 - roll_line * roll_strength;

    // --- Flash lines on open ---
    float scan_freq = 80.0;
    float scan_line = floor(uv.y * scan_freq) / scan_freq;
    float flash_line = step(0.997, random(vec2(scan_line, floor(p * 60.0))));
    col.rgb += flash_line * (1.0 - p) * 0.6;

    // --- Vignette ---
    vec2 vig_uv = uv * (1.0 - uv.yx);
    float vignette = pow(vig_uv.x * vig_uv.y * 15.0, 0.3 * (1.0 - p) + 0.1);
    col.rgb *= clamp(vignette, 0.0, 1.0);

    col.a *= pixel_alpha;
    return col;
}

vec4 window_shader() {
    vec4 c = texelFetch(tex, ivec2(texcoord), 0);
    c = default_post_processing(c);
    float opacity = opacity_threshold(c.w);
    if (opacity == 0.0) return c;
    vec4 anim_c = anim(opacity);
    return default_post_processing(anim_c);
}
