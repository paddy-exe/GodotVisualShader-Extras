shader_type spatial;
// Ben Cloward tutorial						https://www.youtube.com/watch?v=hc6msdFcnA4
// Practical Real-Time Hex-Tiling Paper		https://jcgt.org/published/0011/03/05/

uniform vec2		tex_repeat;
uniform float		sharpness;
uniform float		hex_size;
uniform sampler2D gm_BaseTexture : source_color;

// Functions
float	Round(float num){ return floor(num + .5); }
vec3	Round3(vec3 ivec){ return floor(ivec + vec3(0.5)); }
vec2	Rotate(vec2 _UV, float amount){
	vec2 center = vec2(.5) * tex_repeat;
	_UV -= center;	
	vec2 rot = vec2(cos(amount), sin(amount));
	return vec2((rot.x * _UV.x) + (rot.y * _UV.y), (rot.x * _UV.y) - (rot.y * _UV.x)) + center;
}
vec3	Hash2(vec2 _UV){
	return fract(sin(vec3(
		dot(vec3(_UV.x, _UV.y, _UV.x), vec3(127.09, 311.7, 74.69)), 
		dot(vec3(_UV.y, _UV.x, _UV.x), vec3(269.5, 183.3, 246.1)), 
		dot(vec3(_UV.x, _UV.y, _UV.y), vec3(113.5, 271.89, 124.59))
	)) * 43758.5453);
}
float	Lerp(float val1, float val2, float amount){
	return ( val2 - val1 ) * amount;	
}
vec2	Translate(vec2 _UV, vec2 amount){ return _UV + amount; }
vec2	Scale(vec2 _UV, vec2 amount){ return _UV * amount; }
vec2	Transform(vec2 _UV, float rotation, vec2 scale, vec2 translation){
	return Translate(Scale(Rotate(_UV, rotation), scale), translation);
}	
vec2	RandomTransform(vec2 _UV, vec2 seed){
	vec3 hash = Hash2(seed);
	float rot = mix(-3.1415, 3.1415, fract(hash.b*16.));
	float scl = mix(.8, 1.2, hash.b);
	return Transform(_UV, rot, vec2(scl), hash.xy);
}

// Process
void fragment()
{	
	vec2 base_uv = UV * tex_repeat;
	vec2 uv	= vec2(base_uv);
	uv = vec2(uv.x - ((.5/(1.732 / 2.))*uv.y), (1./(1.732 / 2.))*uv.y) / hex_size;
	
	vec2 coord	= floor(uv);	
	vec4 color	= vec4(coord.x, coord.y, 0., 1.);			
	color.rgb = ((vec3(color.r - color.g) + vec3(0, 1, 2)) * .3333333) + 5./3.;																
	color.rgb = Round3(fract(color.rgb));						
	
	vec4 refcol = vec4(fract(vec2(uv.x, uv.y)), 1, 1);
	refcol.rgb = vec3(refcol.g + refcol.r) - 1.;
	vec4 abscol = vec4(abs(refcol.rgb), 1);
	
	vec4 refswz = vec4(fract(vec2(uv.y, uv.x)), 1, 1);
	vec4 use_col = vec4(fract(vec2(uv.x, uv.y)), 1, 1);
	
	float flip_check = 0.;
	if ( ((refcol.r+refcol.g+refcol.b)/3.) > 0. ){
		use_col = vec4(1.-refswz.x, 1.-refswz.y, refswz.b, refswz.a);
		flip_check = 1.;
	}

	abscol.rgb = abs(vec3(abscol.r, use_col.r, use_col.g));
	use_col.rgb = vec3(
		pow(dot(abscol.rgb, vec3(color.z, color.x, color.y)), sharpness), 
		pow(dot(abscol.rgb, vec3(color.y, color.z, color.x)), sharpness), 
		pow(dot(abscol.rgb, color.rgb), sharpness)
	);

	float coldot = dot(use_col.rgb, vec3(1));
	use_col /= coldot;
	
	vec2 color_swiz1 = vec2(color.a, color.z);
	vec2 color_swiz2 = vec2(color.z, color.x);
	vec2 color_swiz3 = vec2(color.x, color.a);
	
	color.rgb *= flip_check;
	vec4 ruv1 = texture( gm_BaseTexture, RandomTransform(base_uv, color_swiz1 + vec2(color.r) + coord)) * vec4(vec3(use_col.r), 1);
	vec4 ruv2 = texture( gm_BaseTexture, RandomTransform(base_uv, color_swiz2 + vec2(color.g) + coord)) * vec4(vec3(use_col.g), 1);
	vec4 ruv3 = texture( gm_BaseTexture, RandomTransform(base_uv, color_swiz3 + vec2(color.b) + coord)) * vec4(vec3(use_col.b), 1);
	vec4 rout = ruv1 + ruv2 + ruv3;
	
    ALBEDO.rgb = use_col.rgb;//rout.rgb;
}
