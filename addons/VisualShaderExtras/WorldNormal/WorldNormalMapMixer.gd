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

# and

## 2022 Kasper Arnklit Frandsen - Public Domain - No Rights Reserved

@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeWorldNormalMapMixer

func _get_name():
	return "World_Normal_Map_Mixer"

func _get_category():
	return "VisualShaderExtras/WorldNormal"

func _get_description():
	return """This node gives a much better mix between textures where normal maps are involved.
It lets you keep a direction (up/down/left/right) to your mixture so that you can rotate meshes and the direction of the mix stays fixed in world space.
NB: Don't use this on mobile."""

func _is_available(mode, type):
	return mode == VisualShader.MODE_SPATIAL
	
func _is_highend():
	return true #mark as PC only.

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_SCALAR
		1: return VisualShaderNode.PORT_TYPE_VECTOR_3D
	
func _get_output_port_count():
	return 2

func _get_output_port_name(port: int):
	match port:
		0: return "Mask"
		1: return "Normal Map"
	
func _init() -> void:
	set_input_port_default_value(2, Vector3.UP)
	set_input_port_default_value(3, 0.)
	set_input_port_default_value(4, 0.)
	
func _get_input_port_count():
	return 5

func _get_input_port_name(port):
	match port:
		0: return "UV"
		1: return "Normal Map Sampler"
		2: return "Direction Vector"
		3: return "Offset"
		4: return "Fade"
		
func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1: return VisualShaderNode.PORT_TYPE_SAMPLER #sampler
		2: return VisualShaderNode.PORT_TYPE_VECTOR_3D #direction
		3: return VisualShaderNode.PORT_TYPE_SCALAR #offset
		4: return VisualShaderNode.PORT_TYPE_SCALAR #fade

func _get_global_code(mode):
	return """
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
vec3 normal_map_add_z_VisualShaderNodeWorldNormalMapMixer(
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

// Create the texture to pass in like this:
//  vec3 normal_map_texture = textureLod(normal_texture_sampler, inuv, 0.).rgb;
float world_normal_mask_VisualShaderNodeWorldNormalMapMixer(
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

float mask_blend_VisualShaderNodeWorldNormalMapMixer(float offset, float fade, float mask_in) {
	offset *= -1.;

	// 2022 Kasper Arnklit Frandsen - Public Domain - No Rights Reserved
	return smoothstep(offset - fade, offset + fade, mask_in);
}
"""

func _get_code(input_vars, output_vars, mode, type):
	var inuv = "UV"
	if input_vars[0]:
		inuv = input_vars[0]
		
	var code = """
vec3 normal_map_texture = textureLod({normal_texture_sampler}, {inuv}, 0.).rgb;

vec3 normal_applied = normal_map_add_z_VisualShaderNodeWorldNormalMapMixer(
	normal_map_texture, 
	{inuv},
	TANGENT,
	BINORMAL,
	NORMAL);  
float mask = world_normal_mask_VisualShaderNodeWorldNormalMapMixer(
	normal_applied,
	{vector_direction},
	VIEW_MATRIX);
float blended_mask = mask_blend_VisualShaderNodeWorldNormalMapMixer({offset}, {fade}, mask);
{out_float} = blended_mask;
{out_normal_map} = normal_map_texture;
	""".format(
	{
	"inuv" : inuv,
	"normal_texture_sampler": input_vars[1],
	"vector_direction" : input_vars[2],
	"offset": input_vars[3],
	"fade" : input_vars[4],
	"out_float" : output_vars[0],
	"out_normal_map" : output_vars[1]
	})
	return code
