shader_type spatial;
void fragment() {
 float grain = fract(sin(floor(UV.x * 1800.0) * 12.9898) * 43758.5453);
 ALBEDO = vec3(0.48,0.50,0.51) * (0.94 + grain * 0.12);
 METALLIC = 0.8;
 ROUGHNESS = 0.34;
}
