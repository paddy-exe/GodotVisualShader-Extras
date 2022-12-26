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
class_name VisualShaderNodeTiler

func _get_name():
	return "Tiler"

func _init() -> void:
	set_input_port_default_value(0, Vector2(2, 2))
	set_input_port_default_value(1, 4.0)

func _get_category():
	return "VisualShaderExtras/Tiler"

func _get_description():
	return "Tile Stuff"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_input_port_count():
	return 2

func _get_input_port_name(port):
	match port:
		0:
			return "tiling"
		1:
			return "split"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D #tile x and y
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR #split
			
func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "uv"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_2D

func _get_global_code(mode):
	# https://thebookofshaders.com/09/
	return """
	vec2 tile(vec2 _st, float _zoom){
		_st *= _zoom;
		return fract(_st);
	}
	"""

func _get_code(input_vars, output_vars, mode, type):
	# https://thebookofshaders.com/09/
	# I am unsure of the licence. I can't believe it's prohibitive. Let me know.
	return """
	vec2 st = UV.xy/{in_tilexy}.xy;
	st = tile(st,{split}); // split the space in n 
	{out_uv} = st; //emit the new tiled uv
	""".format(
		{
		"in_tilexy":input_vars[0],
		"split":  	input_vars[1],
		"out_uv":	output_vars[0],
		})
