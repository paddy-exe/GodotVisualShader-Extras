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
class_name TempVisualShaderNodeWorldNormalMask

func _get_name():
	return "World Normal Mask"

func _get_version():
	return "1"
	
func _get_category():
	return "VisualShaderExtras/Utility/PR"

func _get_description():
	return LizardShaderLibrary.format_description(self,
	"""Outputs a mask where the given Direction Vector is matched.
Use this to mask out directions like up/down/left/right.
NB: You must supply a normal map with a Z direction. For that use the Normal Map Z Node.""")

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR
	
func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "Mask"
	
func _init() -> void:
	set_input_port_default_value(2, Vector3.UP)
	
func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0: return "UV in"
		1: return "Normal Map with Z"
		2: return "Direction Vector"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2: return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_code(input_vars, output_vars, mode, type):
	var inuv = "UV"
	if input_vars[0]:
		inuv = input_vars[0]
		
	return """
// 2022 Kasper Arnklit Frandsen - Public Domain - No Rights Reserved

// Convert the world up vector into view-space with a matrix multiplication.
vec3 up_vector_viewspace = mat3(VIEW_MATRIX) * {vector_direction};

// Compare the up vector to the surface with the normal map applied using the dot product.
float dot_product = dot(up_vector_viewspace, {normal_rgb});

{out_float} = dot_product;
""".format(
{
"inuv" : inuv,
"normal_rgb": input_vars[1],
"vector_direction" : input_vars[2],
"out_float" : output_vars[0] 
})
