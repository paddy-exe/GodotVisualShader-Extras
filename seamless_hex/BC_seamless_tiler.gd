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
	return 6

func _get_input_port_name(port):
	match port:
		0: return "Tex Repeat"
		1: return "Sharpness"
		2: return "Hex Size"
		3: return "Albedo Texture"
		4: return "Normal Map"
		5: return "fuck"


func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1: return VisualShaderNode.PORT_TYPE_SCALAR
		2: return VisualShaderNode.PORT_TYPE_SCALAR 
		3: return VisualShaderNode.PORT_TYPE_SAMPLER
		4: return VisualShaderNode.PORT_TYPE_SAMPLER
		5: return VisualShaderNode.PORT_TYPE_VECTOR_2D

func _get_global_code(mode):
	return """
// Licence still somewhat in doubt. Am researching.

// Ben Cloward tutorial https://www.youtube.com/watch?v=hc6msdFcnA4
// Practical Real-Time Hex-Tiling Paper https://jcgt.org/published/0011/03/05/
// https://github.com/Gizmo199/non_repeating_hextiling/blob/master/shaders/shd_nonrepeat/shd_nonrepeat.fsh

//const float ONEDIVTHREE = 0.3; // 1./3.; //0.333
//const float FIVEDIVTHREE = 0.67; //5.0/3.0; //1.667
	
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
	// "uv_col" and "use_col" refer to the changed uv coordinates

	//Step 1 : Build a BGR Grid
	vec2 WEIRDNESS = vec2(-0.5,0.5);
	vec2 base_uv = (UV - WEIRDNESS) * {TEX_REPEAT};
	vec2 uv_tiled = base_uv;// - vec2(0.5 * {TEX_REPEAT});
	
	//uv_tiled = vec2(uv_tiled.x - ((.5/(1.732 / 2.))*uv_tiled.y), (1./(1.732 / 2.))*uv_tiled.y) / {HEX_SIZE};
	
	vec4 use_col;
	
	vec2 coord	= trunc(floor(uv_tiled));
	
	
	
	vec4 uv_col	= vec4(coord.x, coord.y, 1., 1.);
	vec3 redMinusGreen = vec3(uv_col.r - uv_col.g);
	vec3 add012 = redMinusGreen + vec3(0., 1., 2.);
	
	float ONEDIVTHREE = 1./ 3.;
	float FIVEDIVTHREE = 5. / 3.;

	vec3 mulONEDIVTHREE = add012 * ONEDIVTHREE;
	vec3 addFIVEDIVTHREE = mulONEDIVTHREE + FIVEDIVTHREE;
	
	vec3 fractionThat = fract(addFIVEDIVTHREE); //DOES NOT LOOK THE SAME!
	
	use_col.rgb = fractionThat;
	if (false) {
		
		
	vec3 RGBgrid = round(fractionThat);
	
		
	//uv_col.rgb = ((vec3(uv_col.r - uv_col.g) + vec3(0, 1, 2)) * ONEDIVTHREE) + FIVEDIVTHREE;

	
	//orig uv_col.rgb = Round3(fract(uv_col.rgb));
	//uv_col.rgb = round(fract(uv_col.rgb)).rgb;
	
	
	
	//Step 2: HEX MASK - based on tiled UV
	//  fract add sub abs
	vec2 first_fraction = vec2(fract(vec2(uv_tiled.x, uv_tiled.y)));
	float addsub = (first_fraction.g + first_fraction.r) - 1.0; //ADD and SUB ONE
	vec4 sub_one = vec4(addsub);
	vec4 abscol = vec4(abs(sub_one.rgb), 1.); //ABSOLUTE : Working
	
	vec2 refswz = first_fraction.yx; //SWIZZ YX
	
	
	//setup use_col val for the < 0. branch
	//orig vec4 use_col = vec4(fract(vec2(uv_tiled.x, uv_tiled.y)), 1, 1);
	use_col = sub_one; //vec4(sub_one.x, sub_one.y, 1, 1);
		
	vec2 inverted_refswz = 1. - refswz; //Looks okay
	
	// if sub_one.rgb > 0 then use_col is built from inverted swizzle
	float flip_check = 0.;
	if ( ((sub_one.r + sub_one.g + sub_one.b)/3.) > 0. ){
		//orig use_col = vec4(1.-refswz.x, 1.-refswz.y, refswz.b, refswz.a);
		use_col.rg = inverted_refswz;
		flip_check = 1.;
	} else {
		use_col.rg = first_fraction.rg;
	}
	
	

	
	//abscol.rgb = abs(vec3(abscol.r, use_col.r, use_col.g));
	abscol.rgb = vec3(abscol.r, use_col.r, use_col.g); //mine abscol COMBINED with use_col

	// test: use_col = abscol; //looks good
	
	vec3 ZXY = vec3(uv_col.z, uv_col.x, uv_col.y);
	use_col = vec4(ZXY,1.);
	
	float dotred = dot(vec3(uv_col.z, uv_col.x, uv_col.y), abscol.rgb);
	use_col = vec4(dotred,dotred,dotred,1.);
	

	
	use_col.rgb = vec3(
		pow(dot(abscol.rgb, vec3(uv_col.z, uv_col.x, uv_col.y)), {SHARPNESS}), 
		pow(dot(abscol.rgb, vec3(uv_col.y, uv_col.z, uv_col.x)), {SHARPNESS}), 
		pow(dot(abscol.rgb, uv_col.rgb), {SHARPNESS})
	);
	
		
	// BC Does this divide after the pow
	//use_col = use_col / dot(use_col.rgb,vec3(1,1,1));

		//STEP 3

		float coldot = dot(use_col.rgb, vec3(1));
		use_col /= coldot;
		
		vec2 color_swiz1 = vec2(uv_col.a, uv_col.z);
		vec2 color_swiz2 = vec2(uv_col.z, uv_col.x);
		vec2 color_swiz3 = vec2(uv_col.x, uv_col.a);
		
		uv_col.rgb *= flip_check;
		
		vec3 rgb_out = vec3(0.,0.,0.);
		
		float unrot_r = 0.;
		float unrot_g = 0.;
		float unrot_b = 0.;
		
		// Get the random rotated uv within the hexagon shape
		vec2 rotated_uv_1 = RandomTransform(base_uv, color_swiz1 + vec2(uv_col.r)
			 + coord, {TEX_REPEAT}, unrot_r);
		vec2 rotated_uv_2 = RandomTransform(base_uv, color_swiz2 + vec2(uv_col.g)
			 + coord, {TEX_REPEAT}, unrot_g);
		vec2 rotated_uv_3 = RandomTransform(base_uv, color_swiz3 + vec2(uv_col.b)
			 + coord, {TEX_REPEAT}, unrot_b);
		
		// If it's a Normal Map, then we must unrotate the rgb colors of the
		// normal map by the amount we just rotated. The if is first_fraction for debugging.
		// Followed Ben Cowan again: https://www.youtube.com/watch?v=BBRmZ1dZCro
		if (false) { 
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
	}
	
	//Pass out the basic UV hex grid - it's usefull.
	{UV_out} = use_col.rg;
	{ALBEDO} = use_col.rgb;
""".format(
	{
		"TEX_REPEAT": input_vars[0],
		"SHARPNESS": input_vars[1],
		"HEX_SIZE": input_vars[2],
		"ALBEDO_TEX": input_vars[3],
		"NM_in": input_vars[4],
		"FUCK": input_vars[5],
		"ALBEDO": output_vars[0],
		"NM_out": output_vars[1],
		"UV_out": output_vars[2]
	})
	return foo
