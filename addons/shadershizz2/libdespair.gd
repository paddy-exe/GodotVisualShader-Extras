extends RefCounted
class_name ShaderFuncRef2

## Seek the shader func name in .
## If not there, add it unadorned
## else ignore.

static func get_funcs(vnode, extra_code="")->String:
	#var uid:int = vnode.get_instance_id() * -1
	var glob_code:String=""
	var sfunc_names = vnode._get_global_func_names()
	for name in sfunc_names:
		var shader_code:String 
		if name in shader_funcs:
			shader_code = shader_funcs[name]
			#shader_code = shader_code.replace(name, "%s%s" % [name,uid])
		else:
			assert("Can't find %s in shader funcs" % name)
			return ""
		#if name not in glob_code:
		glob_code += shader_code + "\n"
		
	if extra_code:
		glob_code += extra_code
	return glob_code

static func fix_funcs(vnode, code:String)->String:
	print("code:",code)
	return code
#	var sfunc_names = vnode._get_global_func_names()
#	var glob_code:String = vnode._get_global_code(0)
#	print(glob_code)
#	for name in sfunc_names:
#		var uid:int = vnode.get_instance_id() * -1
#		#var instance_func : String = "%s%s" % [name,uid]
#		var npos:int = glob_code.find( name,  )
#		if npos:
#			var regex = RegEx.new()
#			var ex:String = "%s[0-9]*" % name
#			print(ex)
#			regex.compile(ex)
#			var result = regex.search_all(glob_code)
#			print(result)
#			if result.size()>0:
#				var res = result[result.size()-1]
#				print(res.get_string())
#				code = code.replace(name, res.get_string())
#	return code


const shader_funcs:Dictionary = {
## _angle in radians
vec2_rotate="""
vec2 vec2_rotate(vec2 _uv, float _angle, vec2 _pivot) {
	_uv -= _pivot;
	_uv = mat2( vec2(cos(_angle), -sin(_angle)), vec2(sin(_angle), cos(_angle)) ) * _uv;
	_uv += _pivot;
	return _uv;
}""",

brick_tile="""
vec2 brick_tile(vec2 _uv, float _zoom, float _shift)
{
	_uv.x += step(1.0, mod(_uv.y, 2.0))  *  _shift;
	return fract(_uv);
}""",

compare="""
float compare(vec4 in1, vec4 in2, float fuzz)
{
	vec4 in1 = in1;
	vec4 in2 = in2;
	float fuzz = fuzz;

	return = dot(abs(in1-in2), vec4(fuzz));
}
""",

## Returns float from 0.0 to 1.0
random_float="""
float random_float(vec2 input) {
	return fract(sin(dot(input.xy, vec2(12.9898,78.233))) * 43758.5453123);
}""",

hash_noise_range="""
// From Juan Linietsky, Ariel Manzur
vec3 hash_noise_range( vec3 p ) 
{
	vec3 p = p;
	p *= mat3(vec3(127.1, 311.7, -53.7), vec3(269.5, 183.3, 77.1), vec3(-301.7, 27.3, 215.3));
	return 2.0 * fract(fract(p)*4375.55) -1.;
}""",

mip_map_lod="""
// mip_map_lod
// Is a way to remove the edges on textures that are tiled
// Use:
// uniform sampler2D albedo_texture;
// float lod = mip_map_lod(UV*tiling * vec2(textureSize(albedo_texture, 0)));
// ALBEDO = textureLod(albedo_texture, some_new_uv, lod).rgb;
// Returns an "lod" according to some dark openGL voodoo
float mip_map_lod(in vec2 _uv, vec2 texture_size)
{
	vec2 uv = uv;
	vec2 texture_size = texture_size;
	vec2 texture_coordinate = uv * texture_size;
	vec2 dx_vtc = dFdx(texture_coordinate);
	vec2 dy_vtc = dFdy(texture_coordinate);
	float delta_max_sqr = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
	float mml = 0.5 * log2(delta_max_sqr);
	return max(0, mml);
}""",

basic_uv_tile="""
vec2 tile(vec2 _uv, float _zoom){
	_uv *= _zoom;
	return fract(_uv);
}""",

normal_map_add_z = """
// Godot strips the z value from imported Normal Maps.
// It does this for two reasons:
// 1. Obtaining better compression because the z can be calculated by shader.
//    Compression boosts speed of CPU to GPU transfer.
// 2. On mobile devices they do not do that calculation. They either ignore the z
//    or do some other calculation, but the normal one (below) is apparently too slow
//    or power-hungry for mobile devices.
//
// Create the texture to pass in like this:
//  vec3 normal_map_texture = textureLod(normal_texture_sampler, inuv, 0.).rgb;
vec3 normal_map_add_z(
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
""",

world_normal_mask = """
// Create the texture to pass in like this:
//  vec3 normal_map_texture = textureLod(normal_texture_sampler, inuv, 0.).rgb;
float world_normal_mask(
	vec3 normal_map_texture, 
	vec3 vector_direction,
	mat4 _VIEW_MATRIX
	) {
	// 2022 Kasper Arnklit Frandsen - Public Domain - No Rights Reserved
	// Convert the world up vector into view-space with a matrix multiplication.
	vec3 up_vector_viewspace = mat3(_VIEW_MATRIX) * vector_direction;

	// Compare the up vector to the surface with the normal map applied using the dot product.
	float dot_product = dot(up_vector_viewspace, normal_map_texture);

	return dot_product;
}
""",

mask_blend = """
float mask_blend(float offset, float fade, float mask_in) {
	offset *= -1.;

	// 2022 Kasper Arnklit Frandsen - Public Domain - No Rights Reserved
	return smoothstep(offset - fade, offset + fade, mask_in);
}
"""
}
