// Ben Cloward tutorial https://www.youtube.com/watch?v=hc6msdFcnA4
// Practical Real-Time Hex-Tiling Paper https://jcgt.org/published/0011/03/05/
shader_type spatial;
uniform sampler2D tex : source_color, filter_linear;
uniform sampler2D NM : hint_normal, filter_linear_mipmap, repeat_disable;
uniform vec2 WEIRDNESS = vec2(1.,-1.);
uniform float TEX_REPEAT = 6.00000;
uniform float SHARPNESS = 16.00000;
uniform float HEX_SIZE = 1.00000;
	
const float ONEDIVTHREE = 1. / 3.;
const float FIVEDIVTHREE = 5. / 3.;

// Functions
//float Round(float num){ return floor(num + .5); }
vec3 Round3(vec3 ivec){ return floor(ivec + vec3(0.5)); }
vec2 Rotate(vec2 _uv, float _angle, float _pivot){
	//vec2 center = vec2(_pivot) * TEX_REPEAT;
	//_uv -= center;
	//vec2 rot = vec2(cos(_angle), sin(_angle));
	//return vec2((rot.x * _uv.x) + (rot.y * _uv.y), (rot.x * _uv.y) - (rot.y * _uv.x)) + center;
	_uv -= _pivot;// * _TEX_REPEAT;
	_uv = mat2( vec2(cos(_angle), -sin(_angle)), vec2(sin(_angle), cos(_angle)) ) * _uv;
	_uv += _pivot;// * _TEX_REPEAT;
	return _uv ;
}
vec3 Hash2(vec2 _uv){
	return fract(sin(vec3(
		dot(vec3(_uv.x, _uv.y, _uv.x), vec3(127.09, 311.7, 74.69)), 
		dot(vec3(_uv.y, _uv.x, _uv.x), vec3(269.5, 183.3, 246.1)), 
		dot(vec3(_uv.x, _uv.y, _uv.y), vec3(113.5, 271.89, 124.59))
	)) * 43758.5453);
}
vec2 Translate(vec2 _uv, vec2 amount){ return _uv + amount; }
vec2 Scale(vec2 _uv, vec2 amount){ return _uv * amount; }
vec2 Transform(vec2 _uv, float rotation, vec2 scale, vec2 translation){
	return Translate(Scale(Rotate(_uv, rotation, 0.5), scale), translation);
}
vec2 RandomTransform(vec2 _uv, vec2 seed, out float unrot){
	vec3 hash = Hash2(seed);
	float rot = mix(-PI, PI, fract(hash.b*16.));
	unrot = TAU - rot;
	float scl = 1.0; //mix(.8, 1.2, hash.b);
	return Transform(_uv, rot, vec2(scl), hash.xy);
}


void fragment() {
	vec2 n_out10p0 = vec2(1.000000, -1.000000);

	vec3 n_out5p0;
	vec3 n_out5p1;
	vec3 n_out5p2;
	

	{
			//Step 1 : Build a BGR Grid
			vec2 base_uv = Rotate(UV,-PI/2.,0.); //(UV + WEIRDNESS) * TEX_REPEAT;
			base_uv = base_uv * TEX_REPEAT;
			
			//Un-slant the final hex uv grid
			float one732div2 = 1.732 / 2.;
			float recip_one732div2 = 1. / one732div2;
			float m1 = base_uv.g * recip_one732div2;
			float div05byone732div2 = 0.5 / one732div2;
			float m2 = base_uv.g * div05byone732div2;
			float s1 = base_uv.r - m2;
			vec2 uv_tiled = vec2(s1, m1) / HEX_SIZE;
			
			vec4 weights;
			
			vec2 coord = floor(uv_tiled);
			
			vec4 uv_col = vec4(coord,0.,0.);
			
			vec3 redMinusGreen = vec3(coord.r - coord.g);
			
			vec3 add012 = redMinusGreen + vec3(0, 1, 2);
		
			vec3 mulONEDIVTHREE = add012 * ONEDIVTHREE;
			vec3 addFIVEDIVTHREE = mulONEDIVTHREE + FIVEDIVTHREE;
			
			vec3 fractionThat = fract(addFIVEDIVTHREE);
			vec3 RGBgrid = round(fractionThat);
			
			//Step 2: HEX MASK - based on tiled UV
			vec2 first_fraction = vec2(fract(uv_tiled));
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
			
			float powred = pow(dotred,SHARPNESS);
			float powgreen = pow(dotgreen,SHARPNESS);
			float powblue = pow(dotblue,SHARPNESS);
			
			vec3 powrgb = vec3(
				pow(dotred,SHARPNESS), 
				pow(dotgreen,SHARPNESS), 
				pow(dotblue,SHARPNESS)
			);
			float powdot111 = dot(powrgb, vec3(1,1,1));
			
			vec3 uv_hex_grid = powrgb / powdot111;
			
			weights = vec4(uv_hex_grid, 1.0);
				
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
			
			vec2 rotated_uv_1 = RandomTransform(base_uv, seed01, unrot_uv1);
			vec2 rotated_uv_2 = RandomTransform(base_uv, seed02, unrot_uv1);
			vec2 rotated_uv_3 = RandomTransform(base_uv, seed03, unrot_uv1);
			
			vec3 albedo1 = texture( tex, rotated_uv_1).rgb * vec3(weights.r);
			vec3 albedo2 = texture( tex, rotated_uv_2).rgb * vec3(weights.g);
			vec3 albedo3 = texture( tex, rotated_uv_3).rgb * vec3(weights.b);
			
			vec3 rgb_out = vec3(0.,0.,0.);
			rgb_out = albedo1.rgb + albedo2.rgb + albedo3.rgb;
			n_out5p0 = rgb_out;
			
			// Not working either
			if (false) {
				// If it's a Normal Map, then we must unrotate the rgb colors of the
				// normal map by the amount we just rotated. The if is only for debugging.
				// Followed Ben Cowan again: https://www.youtube.com/watch?v=BBRmZ1dZCro
				float _pivot = 0.;
				
				vec2 unrot1;
				unrot1 = Rotate(texture( NM, uv_tiled).rg, unrot_uv1, _pivot);
				vec2 mul1 = unrot1 * weights.r;
				
				vec2 unrot2;
				unrot2 = Rotate(texture( NM, uv_tiled).rg, unrot_uv2, _pivot);
				vec2 mul2 = unrot2 * weights.g;
		
				// possibly restore the z component? I dunno.
				//vec3 norm = normal_map_add_z_FOOBAR(
				//	texture( NM, uv_tiled), 
				//	uv_tiled,
				//	TANGENT,
				//	BINORMAL,
				//	NORMAL)
				vec2 unrot3;
				unrot3 = Rotate(texture( NM, uv_tiled).rg, unrot_uv3, _pivot);
				vec2 mul3 = unrot2 * weights.b;
			
				vec2 nm_out = mul1 + mul2 + mul3;
			
				n_out5p1 =  vec3(nm_out.rg, 1.);
			}
			
			//Pass out the basic UV hex grid - it's usefull.
			n_out5p2 = uv_hex_grid;
	}


// Mix:11
	vec3 n_in11p2 = vec3(0.50000, 0.50000, 0.50000);
	
	//Doing a mix so I Can see the hex grid and the textures at the same time
	vec3 n_out11p0 = mix(n_out5p0, n_out5p2, n_in11p2);


// Output:0
	ALBEDO = n_out11p0;


}
