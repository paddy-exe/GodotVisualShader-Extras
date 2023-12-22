# The MIT License
# Copyright © 2022 Inigo Quilez
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

@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeRoundedBox

func _init():
	set_input_port_default_value(1, Vector2(0.5, 0.5))
	set_input_port_default_value(2, Vector2(0.25, 0.25))
	set_input_port_default_value(3, Vector4(0.0, 0.0, 0.0, 0.0))

func _get_name():
	return "SDF RoundedBox Shape"

func _get_category():
	return "VisualShaderExtras/Procedural"

func _get_description():
	return "Signed Distance Field (SDF) Rounded Box Shape"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 4

func _get_input_port_name(port):
	match port:
		0:
			return "UV"
		1:
			return "Position"
		2:
			return "Proportions"
		3:
			return "Radia"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D
		2:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D
		3:
			return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return ""

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return """
		float sdRoundedBox( in vec2 __pos, in vec2 __proportions, in vec4 __radia )
		{
			__radia.xy = (__pos.x > 0.0) ? __radia.xy : vec2(__radia.w, __radia.z);
			__radia.x  = (__pos.y > 0.0) ? __radia.x  : __radia.y;
			vec2 __q = abs(__pos) - __proportions + __radia.x;
			return min(max(__q.x, __q.y), 0.0) + length(max(__q, 0.0)) - __radia.x;
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	
	if input_vars[0]:
		uv = input_vars[0]
	
	return "%s = sdRoundedBox(%s.xy - %s.xy, %s.xy, %s.xyzw);" % [output_vars[0], uv, input_vars[1], input_vars[2], input_vars[3]]
