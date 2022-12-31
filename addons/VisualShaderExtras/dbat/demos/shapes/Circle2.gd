# The MIT License
# Copyright © 2022 Inigo Quilez
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

@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeCircle2

func _init():
	set_input_port_default_value(1, Vector2(0.5, 0.5))#pos
	set_input_port_default_value(2, 0.25) #radius
	set_input_port_default_value(3, 0.25) #feather

func _get_name():
	return "Circle2"

func _get_category():
	return "VisualShaderExtras/Shapes/PR"

func _get_description():
	return "Signed Distance Circle Shape3D with feathering on edge."

func _get_version():
	return "2"
	
func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 4

func _get_input_port_name(port):
	match port:
		0: return "UV"
		1: return "Position"
		2: return "Radius"
		3: return "Feather"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		2: return VisualShaderNode.PORT_TYPE_SCALAR
		3: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "Mask"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return """
//Original code
//float sdCircle(vec2 pos, float r) {
//	return step(length(pos) - r, pos).x;
//}

//New hack - faster than using length func
float circle(vec2 position, float radius, float feather)
{
	return smoothstep(radius, radius + feather, dot(position, position) * 6.0);
}
"""

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	if input_vars[0]:
		uv = input_vars[0]
	return "{out} = circle({uv} - {pos}, {radius}, {feather});" \
	.format({
		"uv": uv,
		"pos": input_vars[1],
		"radius": input_vars[2],
		"feather": input_vars[3],
		"out" : output_vars[0]
	})
