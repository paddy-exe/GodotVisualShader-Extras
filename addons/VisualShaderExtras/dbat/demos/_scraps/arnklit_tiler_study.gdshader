shader_type spatial;
//render_mode specular_schlick_ggx;

uniform sampler2D albedo_texture;
uniform float tiling = 1.0;
uniform float randomize_rotation = 0.0;

float rand(vec2 input) {
        return fract(sin(dot(input.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float mip_map_level(in vec2 texture_coordinate) {
    vec2  dx_vtc = dFdx(texture_coordinate);
    vec2  dy_vtc = dFdy(texture_coordinate);
    float delta_max_sqr = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
    float mml = 0.5 * log2(delta_max_sqr);
    return max(0, mml);
}

void fragment() {
        vec2 tiled_UV_raw = UV * tiling;
        vec2 tiled_UV = fract(tiled_UV_raw) - 0.5;
        vec2 unique_val = floor(UV * tiling) / tiling;
        float rotation = (rand(unique_val) * 2.0 - 1.0) * randomize_rotation * 3.14;
        float cosine = cos(rotation);
        float sine = sin(rotation);
        mat2 rotation_mat = mat2(vec2(cosine, -sine), vec2(sine, cosine));
        vec2 new_uv = rotation_mat * tiled_UV + 0.5;
        float lod = mip_map_level(tiled_UV_raw * vec2(textureSize(albedo_texture, 0)));
        ALBEDO = textureLod(albedo_texture, new_uv, lod).rgb;
        SPECULAR = .1;
    ROUGHNESS = 1.0;
    METALLIC = 0.0;
}
