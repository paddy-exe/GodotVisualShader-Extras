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
class_name VisualShaderNodeWorldNormalMask

func _get_name():
	return "World_Normal_Mask"

func _get_category():
	return "VisualShaderExtras/WorldNormal"

func _get_description():
	return """Outputs a mask where the given Direction Vector is matched.
Use this to mask out directions like up/down/left/right.
NB: You must supply a normal map with a Z direction. For that use the Normal Map Z Node."""

func _is_available(mode, type):
	return mode == VisualShader.MODE_SPATIAL
	
func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR
	
func _get_output_port_count():
	return 1

func _get_output_port_name(port: int):
	return "Mask"
	
func _init() -> void:
	set_input_port_default_value(1, Vector3.UP)
	
func _get_input_port_count():
	return 2

func _get_input_port_name(port):
	match port:
		0: return "Normal Map with Z"
		1: return "Direction Vector"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		1: return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_global_code(mode):
	return """
// Create the texture to pass in like this:
//  vec3 normal_map_texture = textureLod(normal_texture_sampler, inuv, 0.).rgb;
float world_normal_mask_VisualShaderNodeWorldNormalMask(
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
}"""

func _get_code(input_vars, output_vars, mode, type):
	var code = """
{out_float} = world_normal_mask_VisualShaderNodeWorldNormalMask(
	{normal_z_applied},
	{vector_direction},
	VIEW_MATRIX);
""".format(
	{
	"normal_z_applied": input_vars[0],
	"vector_direction" : input_vars[1],
	"out_float" : output_vars[0],
	})
	return code
