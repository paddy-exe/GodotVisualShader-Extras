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
class_name VisualShaderNodeBox

func _init():
	set_input_port_default_value(1, Vector2(0.5, 0.5))
	set_input_port_default_value(2, Vector2(0.25, 0.25))
	set_input_port_default_value(3, 0.)#smoothness

func _get_name():
	return "Box"

func _get_category():
	return "VisualShaderExtras/Shapes"

func _get_description():
	return "Signed Distance Box Shape3D with smoothing."
	
func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 4

func _get_input_port_name(port):
	match port:
		0: return "UV"
		1: return "Position"
		2: return "Proportions"
		3: return "Smoothness"
		
func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		2: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		3: return VisualShaderNode.PORT_TYPE_SCALAR #smoothness

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "Mask"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return """
float sdBox_VisualShaderNodeBoxV2(vec2 _pos, vec2 _proportions, float _feather) {
	vec2 d = abs(_pos) - _proportions; 
	float outside = length(max(d, 0.));
	float inside = min(max(d.x, d.y), 0.);
	float both = outside + inside;
	
	//float f = outside - _feather; //makes a kind of outline
	
	// ok! smoothness is v sensitive tho.
	// when f is 0 the edge is sharp
	float f = _feather; 
	
	return smoothstep(outside, inside, f);
}
"""

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	if input_vars[0]:
		uv = input_vars[0]
	return "{out} = sdBox_VisualShaderNodeBoxV2({uv}-{pos}, {proportions}, {smoothness});" \
	.format({
		"uv": uv,
		"pos": input_vars[1],
		"proportions": input_vars[2],
		"smoothness": input_vars[3],
		"out" : output_vars[0]
	})
	
