shader_type spatial;
uniform sampler2D floor_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D floor_roughness : filter_linear_mipmap, repeat_enable;
uniform sampler2D floor_normal : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D wall_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D wall_roughness : filter_linear_mipmap, repeat_enable;
uniform sampler2D wall_normal : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float repeat_meters = 2.0;
varying vec3 world_position;
varying vec3 world_normal;
void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}
void fragment() {
    vec3 n = normalize(world_normal);
    ALBEDO = vec3(0.8);
    ROUGHNESS = 0.95;
    bool wall = abs(n.y) < 0.5;
    bool floor_face = abs(n.y) >= 0.5 && world_position.y < 0.15;
    if (wall || floor_face) {
        vec3 tangent = wall && abs(n.x) > abs(n.z) ? vec3(0.0,0.0,1.0) : vec3(1.0,0.0,0.0);
        vec3 bitangent = wall ? vec3(0.0,1.0,0.0) : vec3(0.0,0.0,1.0);
        vec2 uv = vec2(dot(world_position,tangent), dot(world_position,bitangent)) / repeat_meters;
        vec3 detail;
        if (wall) {
            ALBEDO = texture(wall_color,uv).rgb;
            ROUGHNESS = texture(wall_roughness,uv).r;
            detail = texture(wall_normal,uv).xyz * 2.0 - 1.0;
        } else {
            ALBEDO = texture(floor_color,uv).rgb;
            ROUGHNESS = texture(floor_roughness,uv).r;
            detail = texture(floor_normal,uv).xyz * 2.0 - 1.0;
        }
        vec3 bumped = normalize(tangent * detail.x * 0.5 + bitangent * detail.y * 0.5 + n * detail.z);
        NORMAL = normalize((VIEW_MATRIX * vec4(bumped,0.0)).xyz);
    }
}
