shader_type spatial;
uniform vec2 HexTiling = vec2(6.000000, 6.000000);
uniform float HexFocus = 2;
uniform sampler2D Albedo : source_color, filter_linear, repeat_enable;
uniform sampler2D NormalMap : hint_normal, filter_linear, repeat_enable;


vec2 HexagonalTilingDbat_Translate(vec2 _UV, vec2 amount){ return _UV + amount; }
vec2 HexagonalTilingDbat_Scale(vec2 _UV, vec2 amount){ return _UV * amount; }
vec2 HexagonalTilingDbat_Rotate(vec2 _uv, float _angle){
	_uv = mat2( vec2(cos(_angle), -sin(_angle)), vec2(sin(_angle), cos(_angle)) ) * _uv;
	return _uv ;

}
vec3 HexagonalTilingDbat_Hash2(vec2 _UV){
	return fract(sin(vec3(
		dot(vec3(_UV.x, _UV.y, _UV.x), vec3(127.09, 311.7, 74.69)), 
		dot(vec3(_UV.y, _UV.x, _UV.x), vec3(269.5, 183.3, 246.1)),
		dot(vec3(_UV.x, _UV.y, _UV.y), vec3(113.5, 271.89, 124.59))
	)) * 43758.5453);
}
vec2 HexagonalTilingDbat_Transform(vec2 _UV, float rotation, vec2 scale, vec2 translation){
	return HexagonalTilingDbat_Translate(
		HexagonalTilingDbat_Scale(
			HexagonalTilingDbat_Rotate(_UV, rotation),
			 scale),
			 translation);
}
// TEX_REPEAT is only passed-in so it can reach another function that needs it.
vec2 HexagonalTilingDbat_RandomTransform(vec2 _UV, vec2 seed, out float rotation) {
	vec3 hash = HexagonalTilingDbat_Hash2(seed);
	float rot = mix(-PI, PI, fract(hash.b*16.));
	float scl = mix(.8, 1.2, hash.b);
	vec2 _rotated = HexagonalTilingDbat_Transform(_UV, rot, vec2(scl), hash.xy);
	rotation = rot;
	return _rotated;
}

vec2 HexagonalTilingDbat_FixNormalMap(vec2 _rg, float _unrot) {
    float rot = TAU -_unrot;
	_rg -= vec2(0.5); //This is the special voodoo. Rodzilla said NormalMaps are centered in color space. Shrug.
    _rg = HexagonalTilingDbat_Rotate(_rg, rot);
	_rg += vec2(0.5);
     return _rg;
}

vec3 HexagonalTilingDbat_RotateAndSample(vec2 _uv, vec2 _seed, float _mask, sampler2D _sam, out vec2 _transformed_uv, out float _rotation ) {
	//float out_rotation_1 = 0.;
	_transformed_uv=HexagonalTilingDbat_RandomTransform(_uv, _seed, _rotation);
	vec4 _read = texture(_sam, _transformed_uv);
	return vec3(_read.xyz) * vec3(_mask);
}


void fragment() {
	vec2 uv_tiled = UV * HexTiling;

///////////////////////////////
//STEP 0 : Unskew the uv map
	float magic_number = 1.73200 / 2.000; //magic numbers
	float n_out60p0 = uv_tiled.y * (0.5 / magic_number);
	float n_out61p0 = uv_tiled.x - n_out60p0;
	float n_out57p0 = 1.0 / (magic_number);
	float n_out59p0 = uv_tiled.y * n_out57p0;
	vec2 n_out62p0 = vec2(n_out61p0, n_out59p0);
	vec2 n_in63p1 = vec2(2.00000, 2.00000);
	vec2 n_out63p0 = n_out62p0 / n_in63p1;

////////////////////////////////////////////
//Step 1 - the repeating grid from floor to round
	vec2 repeating_grid_floor = floor(n_out63p0);
	vec2 fract_of_step_2 = fract(n_out63p0);
	float n_out28p0 = fract_of_step_2.x + fract_of_step_2.y - 1.00;//n_in28p1;
	bool n_out35p0 = n_out28p0 > 0.00;
	float n_out71p0;
	float n_out12p0 = repeating_grid_floor.x - repeating_grid_floor.y;
	vec3 n_out13p0 = vec3(n_out12p0) + vec3(0.00000, 1.00000, 2.00000);
	float n_in16p0 = 3.00000; // this var is vital for the line below
	float n_out16p0 = 1.0 / (n_in16p0); //this line is weird. Using a hard 3.0 in fails!
	vec3 n_out15p0 = n_out13p0 * vec3(n_out16p0);
	float n_in19p0 = 5.00000;
	float n_in19p1 = 3.00000;
	float n_out19p0 = n_in19p0 / n_in19p1;
	vec3 n_out17p0 = n_out15p0 + vec3(n_out19p0);
	vec3 n_out20p0 = fract(n_out17p0);
	vec3 end_round_of_step_1 = round(n_out20p0);
// End step 2
//////////////////////////////////////////

/////////////////////////////////////////////////////////
//Step 2 : From fract to channels out
	vec2 step_02_fract = fract(n_out63p0);
	float stuff = step_02_fract.x + step_02_fract.y;
	float blaargh_n_out28p0 = stuff - 1.00;
	// Compare
	bool greater_than_zero_test = blaargh_n_out28p0 > 0.00;
	float n_out29p0 = abs(blaargh_n_out28p0); //ABS
	vec2 n_out32p0 = vec2(1.0) - step_02_fract.yx;
	vec2 n_out36p0;
	n_out36p0 = mix(step_02_fract, n_out32p0, float(greater_than_zero_test));
	float n_out38p0 = vec3(n_out36p0, 0.0).x;
	float n_out38p1 = vec3(n_out36p0, 0.0).y;
	vec4 n_out37p0 = vec4(n_out29p0, n_out38p0, n_out38p1, 0.00);
// end step 2
/////////////////////////////////////////////////////////
	
//////////////////////
// Making the Channel Masks
	float n_out44p0 = dot(end_round_of_step_1.zxy, vec3(n_out37p0.xyz));
	float n_out45p0 = dot(end_round_of_step_1.yzx, vec3(n_out37p0.xyz));
	float n_out46p0 = dot(end_round_of_step_1, vec3(n_out37p0.xyz));
	vec3 n_out47p0 = vec3(n_out44p0, n_out45p0, n_out46p0);
	vec3 n_out49p0 = pow(n_out47p0, vec3(HexFocus));
	vec3 n_in51p1 = vec3(1.00000, 1.00000, 1.00000);
	float n_out51p0 = dot(n_out49p0, n_in51p1);
	vec3 channel_masks = n_out49p0 / vec3(n_out51p0);
////////////////////////////////

//////////////////////
// Make the seeds
	float a_one_or_zero = mix(0.00, 1.00, float(greater_than_zero_test));// Switch 0 or 1
	vec3 n_out70p0 = vec3(a_one_or_zero) * end_round_of_step_1;

// SEED 1
	vec2 n_out83p0 = repeating_grid_floor + vec2(n_out70p0.z); //Z
	vec2 seed_1 = n_out83p0 + end_round_of_step_1.xy;

// SEED 2
	vec2 n_out82p0 = repeating_grid_floor + vec2(n_out70p0.y); //Y
	vec2 seed_2 = n_out82p0 + end_round_of_step_1.zx;

// SEED 3
	vec2 n_out81p0 = repeating_grid_floor + vec2(n_out70p0.x); //X
	vec2 seed_3 = n_out81p0 + end_round_of_step_1.yz;
//////////////////////





//////////////////////
// HexagonalTilingDbat_Rotate and sample
	vec2 randomly_transformed_uv_1;
	float out_rotation_1 = 0.;
	randomly_transformed_uv_1 = vec2(0.0, 0.0);
	vec3 n_out96p0 = HexagonalTilingDbat_RotateAndSample(uv_tiled, seed_1, channel_masks.x, Albedo, randomly_transformed_uv_1, out_rotation_1);

	vec2 randomly_transformed_uv_2;
	float out_rotation_2 = 0.;
	randomly_transformed_uv_2 = vec2(0.0, 0.0);
	vec3 n_out97p0 = HexagonalTilingDbat_RotateAndSample(uv_tiled, seed_2, channel_masks.y, Albedo, randomly_transformed_uv_2, out_rotation_2);

	vec2 randomly_transformed_uv_3;
	float out_rotation_3 = 0.;
	randomly_transformed_uv_3 = vec2(0.0, 0.0);
	vec3 n_out98p0 = HexagonalTilingDbat_RotateAndSample(uv_tiled, seed_3, channel_masks.z, Albedo, randomly_transformed_uv_3, out_rotation_3);

	//Add the muls to get final output
	vec3 n_out99p0 = n_out96p0 + n_out97p0;
	vec3 _albedo_out = n_out99p0 + n_out98p0; //Final albedo output


	///////////////////////////////////////
	// Normal Map Fix
	vec4 nm_tex_1 = texture(NormalMap, randomly_transformed_uv_1);
	vec2 fnm_1 = vec2(0.0, 0.0);
	fnm_1 = HexagonalTilingDbat_FixNormalMap(nm_tex_1.rg, out_rotation_1);
	vec3 nm_1_rg_rotated = vec3(fnm_1, nm_tex_1.b);

	vec4 nm_tex_2 = texture(NormalMap, randomly_transformed_uv_2);
	vec2 fnm_2 = vec2(0.0, 0.0);
	fnm_2 = HexagonalTilingDbat_FixNormalMap(nm_tex_2.rg, out_rotation_2);
	vec3 nm_2_rg_rotated = vec3(fnm_2, nm_tex_2.b);

	vec4 nm_tex_3 = texture(NormalMap, randomly_transformed_uv_3);
	vec2 fnm_3 = vec2(0.0, 0.0);
	fnm_3 = HexagonalTilingDbat_FixNormalMap(nm_tex_3.rg, out_rotation_3);
	vec3 nm_3_rg_rotated = vec3(fnm_3, nm_tex_3.b);

	//Mul and then add them to get the final output
	vec3 n_out107p0 = nm_1_rg_rotated * vec3(channel_masks.x);
	vec3 n_out108p0 = nm_2_rg_rotated * vec3(channel_masks.y);
	vec3 n_out109p0 = nm_3_rg_rotated * vec3(channel_masks.z);
	vec3 fooob = n_out107p0 + n_out108p0;
	vec3 normal_map_output = fooob + n_out109p0;



// FloatConstant:135
	float nmap_depth = 3.000000;
	float Metallic = 0.000000;
	float Roughness = 1.000000;
	
// Output:0
	ALBEDO = _albedo_out;
	METALLIC = Metallic;
	ROUGHNESS = Roughness;
	SPECULAR = Metallic;
	NORMAL_MAP = normal_map_output;
	NORMAL_MAP_DEPTH = nmap_depth;


}
