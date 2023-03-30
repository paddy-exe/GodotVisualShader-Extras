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
vec2 Rotate(vec2 _uv, float _angle, float _pivot, float TEX_REPEAT){
	//vec2 center = vec2(_pivot) * TEX_REPEAT;
	//_UV -= center;
	//vec2 rot = vec2(cos(amount), sin(amount));
	//return vec2((rot.x * _UV.x) + (rot.y * _UV.y), (rot.x * _UV.y) - (rot.y * _UV.x)) + center;
	
	_uv -= _pivot * TEX_REPEAT;
	_uv = mat2( vec2(cos(_angle), -sin(_angle)), vec2(sin(_angle), cos(_angle)) ) * _uv;
	_uv += _pivot * TEX_REPEAT;
	return _uv ;
		
}
vec2 Transform(vec2 _UV, float rotation, vec2 scale, vec2 translation, float TEX_REPEAT){
	return Translate(Scale(Rotate(_UV, rotation, 0.5, TEX_REPEAT), scale), translation);
}
// TEX_REPEAT is only passed-in so it can reach another function that needs it.
vec2 RandomTransform(vec2 _UV, vec2 seed, float TEX_REPEAT, out float unrot){
	vec3 hash = Hash2(seed);
	float rot = mix(-PI, PI, fract(hash.b*16.));
	unrot = TAU - rot;
	float scl = 1.0; //mix(.8, 1.2, hash.b);
	return Transform(_UV, rot, vec2(scl), hash.xy, TEX_REPEAT);
	//return Rotate(_UV, rot, 0., TEX_REPEAT);
}

vec3 normal_map_add_z_FOOBAR(
	vec3 normal_map_texture, 
	vec2 inuv,
	vec3 _TANGENT,
	vec3 _BINORMAL,
	vec3 _NORMAL) {
	// 2022 Kasper Arnklit Frandsen - Public Domain - No Rights Reserved

	// Unpack the background normal map.
	vec3 bg_normal = normal_map_texture * 2.0 - 1.0;

	// Recalculate z-component of the normal map with the Pythagorean theorem.
	bg_normal.z = sqrt(1.0 - bg_normal.x * bg_normal.x - bg_normal.y * bg_normal.y);

	// Apply the tangent-space normal map to the view-space normals.
	vec3 normal_applied = bg_normal.x * _TANGENT + bg_normal.y * _BINORMAL + bg_normal.z * _NORMAL;
	return normal_applied;
}
"""


func _get_code(input_vars, output_vars, mode, type):
	var foo = """
	// "uv_col" and "weights" refer to the changed uv coordinates

	//Step 1 : Build a BGR Grid
	vec2 WEIRDNESS = {FUCK}; //vec2(0.,1.);
	vec2 base_uv = (UV + WEIRDNESS) * {TEX_REPEAT};
	//vec2 base_uv = (UV) * {TEX_REPEAT};
	//vec2 uv_tiled = base_uv;
	//uv_tiled = vec2(uv_tiled.x - ((.5/(1.732 / 2.))*uv_tiled.y), (1./(1.732 / 2.))*uv_tiled.y) / {HEX_SIZE};
	
	float one732div2 = 1.732 / 2.;
	float recip_one732div2 = 1. / one732div2;
	float m1 = base_uv.g * recip_one732div2;
	float div05byone732div2 = 0.5 / one732div2;
	float m2 = base_uv.g * div05byone732div2;
	float s1 = base_uv.r - m2;
	vec2 uv_tiled = vec2(s1, m1) / {HEX_SIZE};
	
	
	vec4 weights;
	
	vec2 coord	= floor(uv_tiled);
	
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
	vec2 first_fraction = vec2(fract(uv_tiled)); // vec2(uv_tiled.x, uv_tiled.y)));
	float addsub = (first_fraction.g + first_fraction.r) - 1.0; //ADD and SUB ONE
	vec4 sub_one = vec4(addsub);
	vec4 abscol = vec4(abs(sub_one.rgb), 1.); //ABSOLUTE : Working
	
	vec2 refswz = first_fraction.yx; //SWIZZ YX
	
	//setup weights val for the < 0. branch
	weights.rg = first_fraction.rg;
	weights.ba = vec2(0.);
	
	// if sub_one.rgb > 0 then weights is built from inverted swizzle
	float flip_check = 0.;
	if ( ((sub_one.r + sub_one.g + sub_one.b)/3.) > 0. ){
		vec2 inverted_refswz = 1. - refswz; //Looks okay
		weights.rg = inverted_refswz;
		flip_check = 1.;
	}
	
	abscol.rgb = vec3(abscol.r, weights.r, weights.g);

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
	
	weights = vec4(sharphexgrid, 1.0);
		
	//Last step - Don't ask me.
		
	vec3 step3 = RGBgrid * flip_check;
	
	vec2 uvRG = vec2(RGBgrid.r, RGBgrid.g);
	vec2 uvBR = vec2(RGBgrid.b, RGBgrid.r);
	vec2 uvGB = vec2(RGBgrid.g, RGBgrid.b);
	
	vec2 coordPlusR = vec2(coord + RGBgrid.r);
	vec2 coordPlusG = vec2(coord + RGBgrid.g);
	vec2 coordPlusB = vec2(coord + RGBgrid.b);
	
	vec2 seed01 = coordPlusR + uvRG;
	vec2 seed02 = coordPlusG + uvBR;
	vec2 seed03 = coordPlusB + uvGB;
	
	float unrot_uv1 = 0.;
	float unrot_uv2 = 0.;
	float unrot_uv3 = 0.;
	
	//// Get the random rotated uv within the hexagon shape
	
	//RandomTransform(base_uv, seed01, {TEX_REPEAT}, unrot_uv1);
	vec2 rotated_uv_1 = RandomTransform(base_uv, seed01, {TEX_REPEAT}, unrot_uv1);
	vec2 rotated_uv_2 = RandomTransform(base_uv, seed02, {TEX_REPEAT}, unrot_uv1);
	vec2 rotated_uv_3 = RandomTransform(base_uv, seed03, {TEX_REPEAT}, unrot_uv1);
	
	vec3 albedo1 = texture( {ALBEDO_TEX}, rotated_uv_1).rgb * vec3(weights.r);
	vec3 albedo2 = texture( {ALBEDO_TEX}, rotated_uv_2).rgb * vec3(weights.g);
	vec3 albedo3 = texture( {ALBEDO_TEX}, rotated_uv_3).rgb * vec3(weights.b);
	
	vec3 rgb_out = vec3(0.,0.,0.);
	rgb_out = albedo1.rgb + albedo2.rgb + albedo3.rgb;
	{ALBEDO} = rgb_out;
	
	if (false) {
		// If it's a Normal Map, then we must unrotate the rgb colors of the
		// normal map by the amount we just rotated. The if is only for debugging.
		// Followed Ben Cowan again: https://www.youtube.com/watch?v=BBRmZ1dZCro
		float _pivot = 0.;
		
		vec2 unrot1;
		unrot1 = Rotate(texture( {NM_in}, uv_tiled).rg, unrot_uv1, _pivot, {TEX_REPEAT});
		vec2 mul1 = unrot1 * weights.r;
		
		vec2 unrot2;
		unrot2 = Rotate(texture( {NM_in}, uv_tiled).rg, unrot_uv2, _pivot, {TEX_REPEAT});
		vec2 mul2 = unrot2 * weights.g;

		//vec3 norm = normal_map_add_z_FOOBAR(
		//	texture( {NM_in}, uv_tiled), 
		//	uv_tiled,
		//	TANGENT,
		//	BINORMAL,
		//	NORMAL)
		vec2 unrot3;
		unrot3 = Rotate(texture( {NM_in}, uv_tiled).rg, unrot_uv3, _pivot, {TEX_REPEAT});
		vec2 mul3 = unrot2 * weights.b;
	
		vec2 nm_out = mul1 + mul2 + mul3;
	
		{NM_out} =  vec3(nm_out.rg, 1.);
	}
	
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
