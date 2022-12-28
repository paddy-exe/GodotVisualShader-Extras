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

# With assist from https://thebookofshaders.com/09/

@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeTiler

func _get_name():
	return "UVTiler"

func _init() -> void:
	set_input_port_default_value(0, Vector2(2, 2))
	set_input_port_default_value(1, 4.0)
	set_input_port_default_value(2, 0.0)

func _get_category():
	return "VisualShaderExtras/UV"

func _get_description():
	return "Tile a given UV into the given UV tiles and rotate them"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0:
			return "Tiling"
		1:
			return "Split"
		2:
			return "Rotation (Radians)"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
			
func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "UV"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_2D

func _get_global_code(mode):
	return """
		vec2 tile(vec2 _uv, float _zoom){
			_uv *= _zoom;
			return fract(_uv);
		}
		
		vec2 rotate(vec2 _uv, float _angle) {
			_uv -= 0.5;
			_uv = mat2( vec2(cos(_angle), -sin(_angle)), vec2(sin(_angle), cos(_angle)) ) * _uv;
			_uv += 0.5;
			return _uv;
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	var rot:String
	rot = "st = rotate(st, %s);" % input_vars[2] if input_vars[2] != "" else ""
		
	return """
	vec2 st = UV.xy/{in_tilexy}.xy;
	st = tile(st,{split});
	{rot}
	{out_uv} = st;
	""".format(
		{
		"in_tilexy":input_vars[0],
		"split":  	input_vars[1],
		"out_uv":	output_vars[0],
		"rot":		rot
		})
