shader_type spatial;
render_mode blend_mix,cull_back,diffuse_burley,specular_schlick_ggx
;
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform int depth_min_layers = 8;
uniform int depth_max_layers = 16;
uniform vec2 depth_flip = vec2(1.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}

vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}

vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}

float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


float shape_circle(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
    float distance = length(uv);
    return clamp((1.0-distance/size)/edge, 0.0, 1.0);
}

float shape_polygon(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
    float angle = atan(uv.x, uv.y)+3.14159265359;
    float slice = 6.28318530718/sides;
    return clamp((1.0-(cos(floor(0.5+angle/slice)*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}

float shape_star(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
    float angle = atan(uv.x, uv.y);
    float slice = 6.28318530718/sides;
    return clamp((1.0-(cos(floor(angle*sides/6.28318530718-0.5+2.0*step(fract(angle*sides/6.28318530718), 0.5))*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}

float shape_curved_star(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
    float angle = 2.0*(atan(uv.x, uv.y)+3.14159265359);
    float slice = 6.28318530718/sides;
    return clamp((1.0-cos(floor(0.5+0.5*angle/slice)*2.0*slice-angle)*length(uv)/size)/edge, 0.0, 1.0);
}

float shape_rays(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = 0.5*max(edge, 1.0e-8)*size;
	float slice = 6.28318530718/sides;
    float angle = mod(atan(uv.x, uv.y)+3.14159265359, slice)/slice;
    return clamp(min((size-angle)/edge, angle/edge), 0.0, 1.0);
}


const float p_o5346_albedo_color_r = 1.000000000;
const float p_o5346_albedo_color_g = 1.000000000;
const float p_o5346_albedo_color_b = 1.000000000;
const float p_o5346_albedo_color_a = 1.000000000;
const float p_o5346_metallic = 0.000000000;
const float p_o5346_roughness = 1.000000000;
const float p_o5346_emission_energy = 1.000000000;
const float p_o5346_normal = 1.000000000;
const float p_o5346_ao = 1.000000000;
const float p_o5346_depth_scale = 0.500000000;
float o5346_input_depth_tex(vec2 uv, float _seed_variation_) {

return 0.0;
}
const float p_o31570_sigma = 35.700001000;
const float p_o34727_sides = 6.000000000;
const float p_o34727_radius = 0.780000000;
const float p_o34727_edge = 0.000000000;
vec4 o31570_input_in(vec2 uv, float _seed_variation_) {
float o34727_0_1_f = shape_polygon((uv), p_o34727_sides, p_o34727_radius*1.0, p_o34727_edge*1.0);

return vec4(vec3(o34727_0_1_f), 1.0);
}
float o31570_input_amount(vec2 uv, float _seed_variation_) {

return 1.0;
}
vec4 o31570_fct(vec2 uv, float _seed_variation_) {
	float e = 1.0/512.000000000;
	vec4 rv = vec4(0.0);
	float sum = 0.0;
	float sigma = max(0.000001, p_o31570_sigma*o31570_input_amount(uv, _seed_variation_));
	for (float i = -50.0; i <= 50.0; i += 1.0) {
		float coef = exp(-0.5*(pow(i/sigma, 2.0)))/(6.28318530718*sigma*sigma);
		rv += o31570_input_in(uv+vec2(i*e, 0.0), _seed_variation_)*coef;
		sum += coef;
	}
	return rv/sum;
}

void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec4 o31570_0_1_rgba = o31570_fct((uv), _seed_variation_);

	vec3 albedo_tex = ((o31570_0_1_rgba).rgb).rgb;
	albedo_tex = mix(pow((albedo_tex + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex * (1.0 / 12.92),lessThan(albedo_tex,vec3(0.04045)));
	ALBEDO = albedo_tex*vec4(p_o5346_albedo_color_r, p_o5346_albedo_color_g, p_o5346_albedo_color_b, p_o5346_albedo_color_a).rgb;
	METALLIC = 1.0*p_o5346_metallic;
	ROUGHNESS = 1.0*p_o5346_roughness;
	NORMAL = vec3(0.5);
	EMISSION = vec3(0.0)*p_o5346_emission_energy;

}



