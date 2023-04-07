shader_type spatial;
uniform sampler2D Texture2DParameter : source_color;

uniform vec2 HexTiling = vec2(6.000000, 6.000000);
uniform float HexFocus = 2;
uniform sampler2D Albedo : source_color, filter_linear, repeat_enable;
uniform sampler2D NormalMap : hint_normal, filter_linear, repeat_enable;

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


void fragment() {
	vec3 preview = vec3(0.);
	vec2 n_out4p0;
	vec3 n_out4p1;
	vec3 n_out4p2;
	vec3 n_out4p3;
	vec3 n_out4p4;
	vec3 n_out4p5;
// SeamlessHexagonTiling:4
	{
		vec2 uv_tiled = UV * HexTiling;
		
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
		vec3 tmp_49p0 = pow(tmp_47p0, vec3(HexFocus));
		vec3 becooln_in51p1 = vec3(1.00000, 1.00000, 1.00000);
		float tmp_51p0 = dot(tmp_49p0, becooln_in51p1);
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
		
		vec2 uv_transformed_1 = HTD_Transform_uv(uv_tiled, seed_1, out_rotation_1);
		vec2 uv_transformed_2 = HTD_Transform_uv(uv_tiled, seed_2, out_rotation_2);
		vec2 uv_transformed_3 = HTD_Transform_uv(uv_tiled, seed_3, out_rotation_3);
		
		//////////////////////
		// rotate and sample
		vec4 _read_rgb = vec4(0.);
		
		_read_rgb = texture(Texture2DParameter, uv_transformed_1);
		_rgb_1 = _read_rgb.rgb * vec3(channel_masks.x);
		
		_read_rgb = texture(Texture2DParameter, uv_transformed_2);
		_rgb_2 = vec3(_read_rgb.rgb) * vec3(channel_masks.y);
		
		_read_rgb = texture(Texture2DParameter, uv_transformed_3);
		_rgb_3 = vec3(_read_rgb.rgb) * vec3(channel_masks.z);
		
		vec3 _albedo = _rgb_1 + _rgb_2 + _rgb_3;
		
		///////////////////////////////////////
		// Normal Map Fix
		_read_rgb = texture(NormalMap, uv_transformed_1);
		vec2 fixed_rg_1 = vec2(0.0, 0.0);
		fixed_rg_1 = HTD_FixNormalMap(_read_rgb.rg, out_rotation_1);
		_rgb_1 = vec3(fixed_rg_1, 0.) * vec3(channel_masks.x);

		_read_rgb = texture(NormalMap, uv_transformed_1);
		vec2 fixed_rg_2 = vec2(0.0, 0.0);
		fixed_rg_2 = HTD_FixNormalMap(_read_rgb.rg, out_rotation_2);
		_rgb_2 = vec3(fixed_rg_2, 0.) * vec3(channel_masks.y);
		
		_read_rgb = texture(NormalMap, uv_transformed_1);
		vec2 fixed_rg_3 = vec2(0.0, 0.0);
		fixed_rg_3 = HTD_FixNormalMap(_read_rgb.rg, out_rotation_3);
		_rgb_3 = vec3(fixed_rg_3, 0.) * vec3(channel_masks.z);
		
		vec3 _normalmap = _rgb_1 + _rgb_2 + _rgb_3;

		// FloatConstant:135
		float nmap_depth = 3.000000;
		float Metallic = 0.000000;
		float Roughness = 1.000000;
		
	NORMAL_MAP = _normalmap;
	NORMAL_MAP_DEPTH = nmap_depth;
	ALBEDO = _albedo; //n_out4p3;
		
	}
}
