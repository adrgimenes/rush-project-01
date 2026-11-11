shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform float tile_height : hint_range(0.0, 2.0) = 1.0;
uniform float floor_height = 0.0;
uniform float tile_size : hint_range(0.03, 0.3) = 0.1;
uniform float grout_width : hint_range(0.001, 0.01) = 0.003;
uniform vec4 tile_color : source_color = vec4(0.87, 0.86, 0.81, 1.0);
uniform vec4 plaster_color : source_color = vec4(0.57, 0.54, 0.46, 1.0);
uniform vec4 grout_color : source_color = vec4(0.43, 0.42, 0.39, 1.0);
varying vec3 world_position;
varying vec3 world_normal;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 cell = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(cell), hash(cell + vec2(1.0, 0.0)), u.x),
               mix(hash(cell + vec2(0.0, 1.0)), hash(cell + vec2(1.0)), u.x), u.y);
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
    vec3 n = normalize(world_normal);
    ALBEDO = vec3(1.0);
    ROUGHNESS = 1.0;
    bool vertical_wall = abs(n.y) < 0.5;
    float height_above_floor = world_position.y - floor_height;
    if (vertical_wall || height_above_floor >= tile_height) {
        vec3 horizontal = abs(n.x) > abs(n.z) ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
        vec3 vertical = vec3(0.0, 1.0, 0.0);
        vec2 p = vec2(dot(world_position, horizontal), height_above_floor);
        if (!vertical_wall) {
            horizontal = vec3(1.0, 0.0, 0.0);
            vertical = vec3(0.0, 0.0, 1.0);
            p = world_position.xz;
        }
        if (vertical_wall && height_above_floor < tile_height) {
            vec2 grid = p / tile_size;
            vec2 edge = min(fract(grid), 1.0 - fract(grid)) * tile_size;
            float distance_to_edge = min(edge.x, edge.y);
            float aa = max(fwidth(distance_to_edge), 0.0003);
            float tile = smoothstep(grout_width * 0.5 - aa, grout_width * 0.5 + aa, distance_to_edge);
            float variation = (hash(floor(grid)) - 0.5) * 0.055;
            ALBEDO = mix(grout_color.rgb, tile_color.rgb + vec3(variation), tile);
            ROUGHNESS = mix(0.95, 0.36, tile);
            SPECULAR = 0.45;
        } else {
            float fine = noise(p * 170.0);
            float mottling = noise(p * 2.5) - 0.5;
            ALBEDO = plaster_color.rgb * (0.96 + fine * 0.08 + mottling * 0.07);
            ROUGHNESS = 0.96;
            SPECULAR = 0.18;
            float dx = noise(p * 170.0 + vec2(0.25, 0.0)) - fine;
            float dy = noise(p * 170.0 + vec2(0.0, 0.25)) - fine;
            vec3 bumped_normal = normalize(n - 0.22 * (horizontal * dx + vertical * dy));
            NORMAL = normalize((VIEW_MATRIX * vec4(bumped_normal, 0.0)).xyz);
        }
    }
}
