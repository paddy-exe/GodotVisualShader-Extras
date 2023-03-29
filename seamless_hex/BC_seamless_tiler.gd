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
		2: return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_output_port_name(port: int):
	match port:
		0: return "Albedo"
		1: return "Normal Map"
		2: return "Grid"
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
	vec2 WEIRDNESS = vec2(0.,1.);
	vec2 base_uv = (UV - WEIRDNESS) * {TEX_REPEAT};
	//vec2 base_uv = (UV - {FUCK}) * {TEX_REPEAT};
	//vec2 base_uv = (UV) * {TEX_REPEAT};
	vec2 uv_tiled = base_uv;// - vec2(0.5 * {TEX_REPEAT});
	
	uv_tiled = vec2(uv_tiled.x - ((.5/(1.732 / 2.))*uv_tiled.y), (1./(1.732 / 2.))*uv_tiled.y) / {HEX_SIZE};
	
	vec4 use_col;
	
	vec2 coord	= floor(uv_tiled);
	
	//use_col.rg = coord.rg;
	//use_col.b = 1.0;
	
	
	vec4 uv_col	= vec4(coord,1.,1.); //vec4(coord.r, coord.g, 0., 1.);
	
	float rmb = coord.r - coord.g;
	vec3 redMinusGreen = vec3(rmb);
	
	vec3 add012 = redMinusGreen + vec3(0., 1., 2.);
	
	
	float ONEDIVTHREE = 1. / 3.;
	float FIVEDIVTHREE = 5. / 3.;

	vec3 mulONEDIVTHREE = add012 * ONEDIVTHREE;
	vec3 addFIVEDIVTHREE = mulONEDIVTHREE + FIVEDIVTHREE;
	
	vec3 fractionThat = fract(addFIVEDIVTHREE); //DOES NOT LOOK THE SAME!
		
	vec3 RGBgrid = round(fractionThat);
	
	//Step 2: HEX MASK - based on tiled UV
	//  fract add sub abs
	vec2 first_fraction = vec2(fract(vec2(uv_tiled.x, uv_tiled.y)));
	float addsub = (first_fraction.g + first_fraction.r) - 1.0; //ADD and SUB ONE
	vec4 sub_one = vec4(addsub);
	vec4 abscol = vec4(abs(sub_one.rgb), 1.); //ABSOLUTE : Working
	
	vec2 refswz = first_fraction.yx; //SWIZZ YX
	
	//setup use_col val for the < 0. branch
	use_col.rg = first_fraction.rg;
	
	
	// if sub_one.rgb > 0 then use_col is built from inverted swizzle
	float flip_check = 0.;
	if ( ((sub_one.r + sub_one.g + sub_one.b)/3.) > 0. ){
		vec2 inverted_refswz = 1. - refswz; //Looks okay
		use_col.rg = inverted_refswz;
		flip_check = 1.;
	}
	
	abscol.rgb = vec3(abscol.r, use_col.r, use_col.g);

	vec3 ZXY = vec3(RGBgrid.z, RGBgrid.x, RGBgrid.y);
	vec3 YZX = vec3(RGBgrid.y, RGBgrid.z, RGBgrid.x);
	vec3 XYZ = RGBgrid;
	
	float dotred = dot(ZXY, abscol.rgb);
	float dotgreen = dot(YZX, abscol.rgb);
	float dotblue = dot(XYZ, abscol.rgb);
	
	float powred = pow(dotred,{SHARPNESS});
	float powgreen = pow(dotgreen,{SHARPNESS});
	float powblue = pow(dotblue,{SHARPNESS});
	
	vec3 powrgb = vec3(
		pow(dotred,{SHARPNESS}), 
		pow(dotgreen,{SHARPNESS}), 
		pow(dotblue,{SHARPNESS})
	);
	float powdot111 = dot(powrgb, vec3(1,1,1));
	
	vec3 sharphexgrid = powrgb / powdot111;
	
	use_col = vec4(sharphexgrid, 1.0);
		
	//Last step - Don't ask me.
		
	vec3 step3 = RGBgrid * flip_check;
	
	vec2 uvRG = vec2(RGBgrid.r, RGBgrid.g);
	vec2 uvBR = vec2(RGBgrid.b, RGBgrid.r);
	vec2 uvGB = vec2(RGBgrid.g, RGBgrid.b);
	
	vec2 coordPlusR = vec2(coord + RGBgrid.r);
	vec2 coordPlusG = vec2(coord + RGBgrid.g);
	vec2 coordPlusB = vec2(coord + RGBgrid.b);
	
	vec2 gridID1 = coordPlusR + uvRG;
	vec2 gridID2 = coordPlusG + uvBR;
	vec2 gridID3 = coordPlusB + uvGB;
	
	
	float unrot_r = 0.;
	float unrot_g = 0.;
	float unrot_b = 0.;
	
	//// Get the random rotated uv within the hexagon shape
	vec2 rotated_uv_1 = RandomTransform(base_uv, gridID1, {TEX_REPEAT}, unrot_r);
	vec2 rotated_uv_2 = RandomTransform(base_uv, gridID2, {TEX_REPEAT}, unrot_g);
	vec2 rotated_uv_3 = RandomTransform(base_uv, gridID3, {TEX_REPEAT}, unrot_b);
	
	
	vec3 rgb_out = vec3(0.,0.,0.);
	if (false) {
		
		
		// If it's a Normal Map, then we must unrotate the rgb colors of the
		// normal map by the amount we just rotated. The if is first_fraction for debugging.
		// Followed Ben Cowan again: https://www.youtube.com/watch?v=BBRmZ1dZCro
		//if (false) { 
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
		//}
	}
		
	// Apply the albedo to the new uv hexagon
	vec3 ruv1 = texture( {ALBEDO_TEX}, rotated_uv_1).rgb * vec3(use_col.r);
	vec3 ruv2 = texture( {ALBEDO_TEX}, rotated_uv_2).rgb * vec3(use_col.g);
	vec3 ruv3 = texture( {ALBEDO_TEX}, rotated_uv_3).rgb * vec3(use_col.b);
	rgb_out = ruv1.rgb + ruv2.rgb + ruv3.rgb;
	{ALBEDO} = rgb_out;
	
	//Pass out the basic UV hex grid - it's usefull.
	{GRID_out} = sharphexgrid;
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
		"GRID_out": output_vars[2]
	})
	return foo
