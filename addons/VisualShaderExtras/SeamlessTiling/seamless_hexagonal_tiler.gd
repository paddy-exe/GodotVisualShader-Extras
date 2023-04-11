# The MIT License
# Copyright © 2022 Donn Ingle (on shoulders of giants)
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), 
# to deal in the Software without restriction, including without limitation 
# the rights to use, copy, modify, merge, publish, distribute, sublicense, 
# and/or sell copies of the Software, and to permit persons to whom the 
# Software is furnished to do so, subject to the following conditions: 
# The above copyright notice and this permission notice shall be included 
# in all copies or substantial portions of the Software. 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Ben Cloward: Numbers 45,46,47 and 48.
## Start here: https://www.youtube.com/watch?v=hc6msdFcnA4

@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeSeamlessHexagonTiling

func _get_name():
	return "SeamlessHexagonTiling"

func _get_category():
	return "VisualShaderExtras/SeamlessTiling"

func _get_description():
	return """Seamless hexagonal tiler. Taken from the Youtube tuts by Ben Cloward
	Numbers 45,46,47 and 48.
	Link: https://www.youtube.com/watch?v=hc6msdFcnA4"""

func _is_available(mode, type):
	return mode == VisualShader.MODE_SPATIAL
	
func _is_highend():
	return true #mark as PC only.
	
func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

enum {KEY, NAME, PORT_TYPE_IN, PORT_TYPE_OUT}
enum _in {UV,A,ORM,NM,HTILE,HF}
enum _out {A,ORM,FNM} #,UV1,UV2,UV3,M,S1,S2,S3}
const names_in := [
	#[key, name, type_in, type_out]
	["UV", "UV", VisualShaderNode.PORT_TYPE_VECTOR_2D, VisualShaderNode.PORT_TYPE_VECTOR_2D],
	["A",  "Albedo", VisualShaderNode.PORT_TYPE_SAMPLER, VisualShaderNode.PORT_TYPE_VECTOR_4D],
	["ORM","ORM", VisualShaderNode.PORT_TYPE_SAMPLER, VisualShaderNode.PORT_TYPE_VECTOR_3D],
	["NM",  "NormalMap", VisualShaderNode.PORT_TYPE_SAMPLER, VisualShaderNode.PORT_TYPE_VECTOR_3D],
	["HTILE", "HexTiling", VisualShaderNode.PORT_TYPE_VECTOR_2D, VisualShaderNode.PORT_TYPE_VECTOR_2D],
	["HF", "HexFocus", VisualShaderNode.PORT_TYPE_SCALAR, VisualShaderNode.PORT_TYPE_SCALAR]
]
const names_out := [
	["A", "Albedo", VisualShaderNode.PORT_TYPE_VECTOR_3D, VisualShaderNode.PORT_TYPE_VECTOR_3D],
	["ORM", "ORM", VisualShaderNode.PORT_TYPE_VECTOR_3D, VisualShaderNode.PORT_TYPE_VECTOR_3D],
	["FNM", "NormalMap", VisualShaderNode.PORT_TYPE_VECTOR_3D, VisualShaderNode.PORT_TYPE_VECTOR_3D],
#	["UV1", "UV1", VisualShaderNode.PORT_TYPE_VECTOR_2D, VisualShaderNode.PORT_TYPE_VECTOR_2D],
#	["UV2", "UV2", VisualShaderNode.PORT_TYPE_VECTOR_2D, VisualShaderNode.PORT_TYPE_VECTOR_2D],
#	["UV3", "UV3", VisualShaderNode.PORT_TYPE_VECTOR_2D, VisualShaderNode.PORT_TYPE_VECTOR_2D],
#	["M", "Masks", VisualShaderNode.PORT_TYPE_VECTOR_3D, VisualShaderNode.PORT_TYPE_VECTOR_3D],
#	["S1", "Seed1", VisualShaderNode.PORT_TYPE_VECTOR_2D, VisualShaderNode.PORT_TYPE_VECTOR_2D],
#	["S2", "Seed2", VisualShaderNode.PORT_TYPE_VECTOR_2D, VisualShaderNode.PORT_TYPE_VECTOR_2D],
#	["S3", "Seed3", VisualShaderNode.PORT_TYPE_VECTOR_2D, VisualShaderNode.PORT_TYPE_VECTOR_2D],
]
	
func _get_output_port_count():
	return names_out.size()
	
func _get_output_port_type(port):
	return names_out[port][PORT_TYPE_OUT]

func _get_output_port_name(port: int):
	return names_out[port][1]

func _init() -> void:
	set_input_port_default_value(_in.HTILE, Vector2(12.0,12.0))
	set_input_port_default_value(_in.HF, 8.0)
	
func _get_input_port_count():
	return names_in.size()

func _get_input_port_name(port):
	return names_in[port][NAME]

func _get_input_port_type(port):
	return names_in[port][PORT_TYPE_IN]

func _get_global_code(mode):
	return """
vec2 HTD_Translate(vec2 _UV, vec2 amount){ return _UV + amount; }
vec2 HTD_Scale(vec2 _UV, vec2 amount){ return _UV * amount; }

vec2 HTD_Rotate(vec2 _uv, float _angle){
	_uv = mat2( vec2(cos(_angle), -sin(_angle)), vec2(sin(_angle), cos(_angle)) ) * _uv;
	return _uv ;
}
vec3 HTD_Hash2(vec2 _UV){
	return fract(sin(vec3(
		dot(vec3(_UV.x, _UV.y, _UV.x), vec3(127.09, 311.7, 74.69)), 
		dot(vec3(_UV.y, _UV.x, _UV.x), vec3(269.5, 183.3, 246.1)),
		dot(vec3(_UV.x, _UV.y, _UV.y), vec3(113.5, 271.89, 124.59))
	)) * 43758.5453);
}
vec2 HTD_Transform(vec2 _UV, float rotation, vec2 scale, vec2 translation){
	return HTD_Translate(
		HTD_Scale(
			HTD_Rotate(_UV, rotation),
			 scale),
			 translation);
}

vec2 HTD_FixNormalMap(vec2 _rg, float _unrot) {
	float rot = TAU -_unrot;
	_rg -= vec2(0.5); //This is the special voodoo. Rodzilla said NormalMaps are centered in color space. Shrug.
	_rg = HTD_Rotate(_rg, rot);
	_rg += vec2(0.5);
	 return _rg;
}

vec2 HTD_Transform_uv(vec2 _uv, vec2 seed, out float out_rotation) {
	vec3 hash = HTD_Hash2(seed);
	float rot = mix(-PI, PI, fract(hash.b*16.));
	float scl = mix(.8, 1.2, hash.b);
	out_rotation = rot;
	return HTD_Transform(_uv, rot, vec2(scl), hash.xy);
}

"""

var xyz:={"1":"x","2":"y","3":"z"}
func _get_code(input_vars, output_vars, mode, type):
	var outputs=""
	
	var inuv := "UV"
	if input_vars[_in.UV]:
		inuv = input_vars[_in.UV]
	
	# code for everything but normal map:
	var r_and_s = """
_read_rgb = texture({sampler}, uv_transformed_{counter});
_rgb_{counter} = _read_rgb.rgb * vec3(channel_masks.{xyorz});
"""
	#Handle Albedo Input
	var sam_albedo:=""
	if input_vars[_in.A]:
		sam_albedo += "_read_rgb = vec4(0.);"
		for e in ["1","2","3"]:
			var tmp := r_and_s.format({"sampler":input_vars[_in.A]})
			sam_albedo+= tmp.format({"counter":e,"xyorz":xyz[e]})
		sam_albedo += """
//Add them
{A} = _rgb_1 + _rgb_2 + _rgb_3;
		""".format(	{"A": output_vars[_out.A]} )
		
	#Handle ORM Input
	var sam_orm:=""
	if input_vars[_in.ORM]:
		sam_orm += "_read_rgb = vec4(0.);"
		for e in ["1","2","3"]:
			var tmp := r_and_s.format({"sampler":input_vars[_in.ORM]})
			sam_orm+= tmp.format({"counter":e,"xyorz":xyz[e]})
		sam_orm += """
//Add them
{ORM} = _rgb_1 + _rgb_2 + _rgb_3;
		""".format(	{"ORM": output_vars[_out.ORM]} )

	# Handle Normal Map
	var sam_nm:=""
	if input_vars[_in.NM]:
		var fix_normal = """
_read_rgb = texture({sampler}, uv_transformed_{counter});
fixed_rg = vec2(0.0, 0.0);
fixed_rg = HTD_FixNormalMap(_read_rgb.rg, out_rotation_{counter});
_rgb_{counter} = vec3(fixed_rg, 0.) * vec3(channel_masks.{xyorz});
		"""
		sam_nm += "_read_rgb = vec4(0.); vec2 fixed_rg;"
		for e in ["1","2","3"]:
			var tmp := fix_normal.format({"sampler":input_vars[_in.NM]})
			sam_nm+= tmp.format({"counter":e,"xyorz":xyz[e]})
		sam_nm += """
//Add them
{NM} = _rgb_1 + _rgb_2 + _rgb_3;
		""".format(	{"NM": output_vars[_out.FNM]} )
		
	var return_shader = shader.format(
	{
	"uv_in" : inuv,
	"HexTiling": input_vars[_in.HTILE],
	"HexFocus": input_vars[_in.HF],
	"albedo_transform_and_sample":sam_albedo,
	"orm_transform_and_sample":sam_orm,
	"normalmap_transform_and_sample_and_fix":sam_nm,
#	"UV1" : output_vars[_out.UV1],
#	"UV2" : output_vars[_out.UV2],
#	"UV3" : output_vars[_out.UV3],
#	"MASKS" : output_vars[_out.M],
#	"SEED1" : output_vars[_out.S1],
#	"SEED2" : output_vars[_out.S2],
#	"SEED3" : output_vars[_out.S3]
	})
	return return_shader

var shader="""
vec2 uv_tiled = {uv_in} * {HexTiling};

///////////////////////////////
//STEP 0 : Unskew the uv map
float magic_number = 1.73200 / 2.000; //magic numbers
float tmp_60p0 = uv_tiled.y * (0.5 / magic_number);
float tmp_61p0 = uv_tiled.x - tmp_60p0;
float tmp_57p0 = 1.0 / (magic_number);
float tmp_59p0 = uv_tiled.y * tmp_57p0;
vec2 tmp_62p0 = vec2(tmp_61p0, tmp_59p0);
vec2 becooln_in63p1 = vec2(2.00000, 2.00000);
vec2 uv_fixed = tmp_62p0 / becooln_in63p1;


////////////////////////////////////////////
//Step 1 - the repeating grid from floor to round
vec2 repeating_grid_floor = floor(uv_fixed);
vec2 fract_of_step_2 = fract(uv_fixed);
float tmp_28p0 = fract_of_step_2.x + fract_of_step_2.y - 1.00;//becooln_in28p1;
//bool tmp_35p0 = tmp_28p0 > 0.00;
float tmp_71p0;
float tmp_12p0 = repeating_grid_floor.x - repeating_grid_floor.y;
vec3 tmp_13p0 = vec3(tmp_12p0) + vec3(0.00000, 1.00000, 2.00000);
float tmp_var = 3.00000; // this var is vital for the line below
float tmp_16p0 = 1.0 / (tmp_var); //this line is weird. Using a hard 3.0 in fails!
vec3 tmp_15p0 = tmp_13p0 * vec3(tmp_16p0);
float becooln_in19p0 = 5.00000;
float becooln_in19p1 = 3.00000;
float tmp_19p0 = becooln_in19p0 / becooln_in19p1;
vec3 tmp_17p0 = tmp_15p0 + vec3(tmp_19p0);
vec3 tmp_20p0 = fract(tmp_17p0);
vec3 end_round_of_step_1 = round(tmp_20p0);

/////////////////////////////////////////////////////////
//Step 2 : From fract to channels out to masks
vec2 step_02_fract = fract(uv_fixed);
float stuff = step_02_fract.x + step_02_fract.y;
float to_abs = stuff - 1.00;
// Compare
bool greater_than_zero_test = to_abs > 0.00;
float tmp_29p0 = abs(to_abs); //ABS
vec2 tmp_32p0 = vec2(1.0) - step_02_fract.yx;
vec2 tmp_36p0;
tmp_36p0 = mix(step_02_fract, tmp_32p0, float(greater_than_zero_test));
vec4 tmp_37p0 = vec4(tmp_29p0, tmp_36p0.x, tmp_36p0.y, 0.00);

// Making the Channel Masks
float tmp_44p0 = dot(end_round_of_step_1.zxy, vec3(tmp_37p0.xyz));
float tmp_45p0 = dot(end_round_of_step_1.yzx, vec3(tmp_37p0.xyz));
float tmp_46p0 = dot(end_round_of_step_1, vec3(tmp_37p0.xyz));
vec3 tmp_47p0 = vec3(tmp_44p0, tmp_45p0, tmp_46p0);
vec3 tmp_49p0 = pow(tmp_47p0, vec3({HexFocus}));
vec3 vec111 = vec3(1.00000, 1.00000, 1.00000);
float tmp_51p0 = dot(tmp_49p0, vec111);
vec3 channel_masks = tmp_49p0 / vec3(tmp_51p0);

//////////////////////
// Make the seeds
float a_one_or_zero = mix(0.00, 1.00, float(greater_than_zero_test));// Switch 0 or 1
vec3 tmp_70p0 = vec3(a_one_or_zero) * end_round_of_step_1;

// SEED 1
vec2 tmp_83p0 = repeating_grid_floor + vec2(tmp_70p0.z); //Z
vec2 seed_1 = tmp_83p0 + end_round_of_step_1.xy;

// SEED 2
vec2 tmp_82p0 = repeating_grid_floor + vec2(tmp_70p0.y); //Y
vec2 seed_2 = tmp_82p0 + end_round_of_step_1.zx;

// SEED 3
vec2 tmp_81p0 = repeating_grid_floor + vec2(tmp_70p0.x); //X
vec2 seed_3 = tmp_81p0 + end_round_of_step_1.yz;

//////////////////////
float out_rotation_1;
float out_rotation_2;
float out_rotation_3;
vec3 _rgb_1;
vec3 _rgb_2;
vec3 _rgb_3;

//////////////////////
// rotate and sample
vec2 uv_transformed_1 = HTD_Transform_uv(uv_tiled, seed_1, out_rotation_1);
vec2 uv_transformed_2 = HTD_Transform_uv(uv_tiled, seed_2, out_rotation_2);
vec2 uv_transformed_3 = HTD_Transform_uv(uv_tiled, seed_3, out_rotation_3);

// Now output all the rgb for the maps coming in
vec4 _read_rgb;

{albedo_transform_and_sample}
{orm_transform_and_sample}
{normalmap_transform_and_sample_and_fix}
"""
#"""
#{UV1} = uv_transformed_1;
#{UV2} = uv_transformed_2;
#{UV3} = uv_transformed_3;
#
#{MASKS} = channel_masks;
#{SEED1} = seed_1;
#{SEED2} = seed_2;
#{SEED3} = seed_3;
#"""
