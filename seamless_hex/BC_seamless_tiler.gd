@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeBCSeamlessTiling

func _get_name():
	return "BCSeamlessTiling"

func _get_category():
	return "VisualShaderExtras/dev"

func _get_description():
	return """..."""

func _is_available(mode, type):
	return mode == VisualShader.MODE_SPATIAL
	
func _is_highend():
	return true #mark as PC only.

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_output_port_count():
	return 3
	
func _get_output_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		1: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2: return VisualShaderNode.PORT_TYPE_VECTOR_2D

func _get_output_port_name(port: int):
	match port:
		0: return "Albedo"
		1: return "Normal Map"
		2: return "UV"
#		3: return "Roughness"
#		4: return "Metallic"
#		5: return "Specular"

	
func _init() -> void:
	set_input_port_default_value(0, Vector2(1,1))
	set_input_port_default_value(1, 1.)
	set_input_port_default_value(2, 1.)
	
func _get_input_port_count():
	return 5

func _get_input_port_name(port):
	match port:
		0: return "Tex Repeat"
		1: return "Sharpness"
		2: return "Hex Size"
		3: return "Albedo Texture"
		4: return "Normal Map"


func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1: return VisualShaderNode.PORT_TYPE_SCALAR
		2: return VisualShaderNode.PORT_TYPE_SCALAR 
		3: return VisualShaderNode.PORT_TYPE_SAMPLER
		4: return VisualShaderNode.PORT_TYPE_SAMPLER

func _get_global_code(mode):
	return """
// Licence still somewhat in doubt. Am researching.

// Ben Cloward tutorial https://www.youtube.com/watch?v=hc6msdFcnA4
// Practical Real-Time Hex-Tiling Paper https://jcgt.org/published/0011/03/05/
// https://github.com/Gizmo199/non_repeating_hextiling/blob/master/shaders/shd_nonrepeat/shd_nonrepeat.fsh

// Functions
//float Round(float num){ return floor(num + .5); }
vec3 Round3(vec3 ivec){ return floor(ivec + vec3(0.5)); }
vec2 Rotate(vec2 _UV, float amount, float _pivot, float TEX_REPEAT){
	vec2 center = vec2(_pivot) * TEX_REPEAT;
	_UV -= center;
	vec2 rot = vec2(cos(amount), sin(amount));
	return vec2((rot.x * _UV.x) + (rot.y * _UV.y), (rot.x * _UV.y) - (rot.y * _UV.x)) + center;
}
vec3 Hash2(vec2 _UV){
	return fract(sin(vec3(
		dot(vec3(_UV.x, _UV.y, _UV.x), vec3(127.09, 311.7, 74.69)), 
		dot(vec3(_UV.y, _UV.x, _UV.x), vec3(269.5, 183.3, 246.1)), 
		dot(vec3(_UV.x, _UV.y, _UV.y), vec3(113.5, 271.89, 124.59))
	)) * 43758.5453);
}
//float Lerp(float val1, float val2, float amount){
//	return ( val2 - val1 ) * amount;
//}
vec2 Translate(vec2 _UV, vec2 amount){ return _UV + amount; }
vec2 Scale(vec2 _UV, vec2 amount){ return _UV * amount; }
vec2 Transform(vec2 _UV, float rotation, vec2 scale, vec2 translation, float TEX_REPEAT){
	return Translate(Scale(Rotate(_UV, rotation, 0.5, TEX_REPEAT), scale), translation);
}
// TEX_REPEAT is only passed-in so it can reach another function that needs it.
vec2 RandomTransform(vec2 _UV, vec2 seed, float TEX_REPEAT, out float unrot){
	vec3 hash = Hash2(seed);
	float rot = mix(-3.1415, 3.1415, fract(hash.b*16.));
	unrot = TAU - rot;
	float scl = mix(.8, 1.2, hash.b);
	return Transform(_UV, rot, vec2(scl), hash.xy, TEX_REPEAT);
}
"""


func _get_code(input_vars, output_vars, mode, type):
	var foo = """
	// "color" and "use_col" refer to the changed uv coordinates
	
	vec2 base_uv = UV * {TEX_REPEAT};
	vec2 uv	= vec2(base_uv);
	uv = vec2(uv.x - ((.5/(1.732 / 2.))*uv.y), (1./(1.732 / 2.))*uv.y) / {HEX_SIZE};
	
	vec2 coord	= floor(uv);
	vec4 color	= vec4(coord.x, coord.y, 0., 1.);
	color.rgb = ((vec3(color.r - color.g) + vec3(0, 1, 2)) * .3333333) + 5./3.;
	color.rgb = Round3(fract(color.rgb));
	
	vec4 refcol = vec4(fract(vec2(uv.x, uv.y)), 1., 1.);
	refcol.rgb = vec3(refcol.g + refcol.r) - 1.;
	vec4 abscol = vec4(abs(refcol.rgb), 1.);
	
	vec4 refswz = vec4(fract(vec2(uv.y, uv.x)), 1, 1);
	vec4 use_col = vec4(fract(vec2(uv.x, uv.y)), 1, 1);
	
	float flip_check = 0.;
	if ( ((refcol.r+refcol.g+refcol.b)/3.) > 0. ){
		use_col = vec4(1.-refswz.x, 1.-refswz.y, refswz.b, refswz.a);
		flip_check = 1.;
	}

	abscol.rgb = abs(vec3(abscol.r, use_col.r, use_col.g));
	use_col.rgb = vec3(
		pow(dot(abscol.rgb, vec3(color.z, color.x, color.y)), {SHARPNESS}), 
		pow(dot(abscol.rgb, vec3(color.y, color.z, color.x)), {SHARPNESS}), 
		pow(dot(abscol.rgb, color.rgb), {SHARPNESS})
	);

	float coldot = dot(use_col.rgb, vec3(1));
	use_col /= coldot;
	
	vec2 color_swiz1 = vec2(color.a, color.z);
	vec2 color_swiz2 = vec2(color.z, color.x);
	vec2 color_swiz3 = vec2(color.x, color.a);
	
	color.rgb *= flip_check;
	
	vec3 rgb_out = vec3(0.,0.,0.);
	
	float unrot_r = 0.;
	float unrot_g = 0.;
	float unrot_b = 0.;
	
	// Get the random rotated uv within the hexagon shape
	vec2 rotated_uv_1 = RandomTransform(base_uv, color_swiz1 + vec2(color.r)
		 + coord, {TEX_REPEAT}, unrot_r);
	vec2 rotated_uv_2 = RandomTransform(base_uv, color_swiz2 + vec2(color.g)
		 + coord, {TEX_REPEAT}, unrot_g);
	vec2 rotated_uv_3 = RandomTransform(base_uv, color_swiz3 + vec2(color.b)
		 + coord, {TEX_REPEAT}, unrot_b);
	
	// If it's a Normal Map, then we must unrotate the rgb colors of the
	// normal map by the amount we just rotated. The if is tmp for debugging.
	// Followed Ben Cowan again: https://www.youtube.com/watch?v=BBRmZ1dZCro
	if (true) { 
		vec2 unrotated_uvmap_rg = vec2(0.,0.);
		vec2 rotated_uv = vec2(0.,0.);
		vec3 mulv3 = vec3(0.,0.,0.);
		vec3 sam = vec3(0.,0.,0.);
		float _pivot = 0.;
		
		sam = texture( {NM_in}, rotated_uv_1).rgb;
		unrotated_uvmap_rg = Rotate(sam.rg, unrot_r, _pivot, {TEX_REPEAT});
		mulv3 = vec3(unrotated_uvmap_rg, sam.b) * vec3(use_col.r);
		rgb_out = mulv3;
		
		sam = texture( {NM_in}, rotated_uv_2).rgb;
		unrotated_uvmap_rg = Rotate(sam.rg, unrot_g, _pivot, {TEX_REPEAT});
		mulv3 = vec3(unrotated_uvmap_rg, sam.b) * vec3(use_col.g);
		rgb_out += mulv3;
		
		//unrotated_uvmap_rg = Rotate(sam.rg, unrot_b, _pivot, {TEX_REPEAT});
		//sam = texture( {NM_in}, rotated_uv_3).rgb;
		//mulv3 = vec3(unrotated_uvmap_rg, sam.b) * vec3(use_col.b);
		//rgb_out += mulv3;
			
		{NM_out} =  rgb_out;
	}
	
	// Apply the albedo to the new uv hexagon
	vec3 ruv1 = texture( {ALBEDO_TEX}, rotated_uv_1).rgb * vec3(use_col.r);
	vec3 ruv2 = texture( {ALBEDO_TEX}, rotated_uv_2).rgb * vec3(use_col.g);
	vec3 ruv3 = texture( {ALBEDO_TEX}, rotated_uv_3).rgb * vec3(use_col.b);
	rgb_out = ruv1.rgb + ruv2.rgb + ruv3.rgb;
	{ALBEDO} = rgb_out;

	//Pass out the basic UV hex grid - it's usefull.
	{UV_out} = use_col.rg;
""".format(
	{
		"TEX_REPEAT": input_vars[0],
		"SHARPNESS": input_vars[1],
		"HEX_SIZE": input_vars[2],
		"ALBEDO_TEX": input_vars[3],
		"NM_in": input_vars[4],
		"ALBEDO": output_vars[0],
		"NM_out": output_vars[1],
		"UV_out": output_vars[2]
	})
	return foo
