shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float intensity : hint_range(0.0, 1.0) = 0.8;
uniform float vertical_resolution : hint_range(180.0, 720.0, 1.0) = 360.0;
uniform float grain_strength : hint_range(0.0, 0.15) = 0.035;
uniform float vignette_strength : hint_range(0.0, 0.8) = 0.25;
uniform float chromatic_pixels : hint_range(0.0, 2.0) = 0.35;
uniform float brightness : hint_range(0.5, 1.2) = 0.90;
uniform float shadow_gamma : hint_range(0.8, 1.4) = 1.07;
uniform float saturation : hint_range(0.0, 1.5) = 0.85;
uniform float contrast : hint_range(0.5, 1.5) = 1.06;
uniform float scanline_strength : hint_range(0.0, 0.2) = 0.025;
uniform float color_levels : hint_range(16.0, 256.0, 1.0) = 64.0;

float noise(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	float rows = min(vertical_resolution, resolution.y);
	vec2 grid = vec2(rows * resolution.x / resolution.y, rows);
	vec2 pixel = floor(SCREEN_UV * grid);
	vec2 uv = (pixel + 0.5) / grid;
	vec2 shift = vec2(chromatic_pixels / grid.x, 0.0);
	vec3 col = texture(screen_texture, uv).rgb;
	col.r = texture(screen_texture, clamp(uv + shift, vec2(0.0), vec2(1.0))).r;
	col.b = texture(screen_texture, clamp(uv - shift, vec2(0.0), vec2(1.0))).b;
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(vec3(luma), col, saturation);
	col *= vec3(1.02, 1.01, 0.94);
	col = pow(max(col, vec3(0.0)), vec3(shadow_gamma)) * brightness;
	col = max((col - 0.5) * contrast + 0.5, vec3(0.0));
	float grain = noise(pixel + vec2(floor(TIME * 24.0), 0.0)) - 0.5;
	// Noise fades into full darkness, keeping unlit areas black.
	col += grain * grain_strength * smoothstep(0.0, 0.15, luma);
	float dither = (noise(pixel) - 0.5) / color_levels;
	col = floor(clamp(col + dither, 0.0, 1.0) * color_levels + 0.5) / color_levels;
	col *= 1.0 - scanline_strength * (0.5 + 0.5 * sin(SCREEN_UV.y * grid.y * 3.14159265));
	vec2 centered = SCREEN_UV * 2.0 - 1.0;
	col *= 1.0 - vignette_strength * smoothstep(0.2, 1.5, dot(centered, centered));
	vec3 original = texture(screen_texture, SCREEN_UV).rgb;
	COLOR = vec4(mix(original, clamp(col, 0.0, 1.0), intensity), 1.0);
}
