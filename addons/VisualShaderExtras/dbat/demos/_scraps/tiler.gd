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
class_name TempVisualShaderNodeTiler1


func _get_name():
	return "Tiler"

var LSL:LizardShaderLib

func _init() -> void:
	LSL = LizardShaderLib.new()
	
	set_input_port_default_value(0, Vector2(2, 2))
	set_input_port_default_value(1, 4.0) #zoom
	set_input_port_default_value(2, 0.0) #rot
	set_input_port_default_value(3, 0.0) #randomize
	
func _get_category():
	return "dbatWork/Tiler"

func _get_description():
	return "Tile Stuff"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_input_port_count():
	return 4

func _get_input_port_name(port):
	match port:
		0: return "Tiling"
		1: return "Zoom"
		2: return "Rotation radians"
		3: return "Randomize rotation"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D #tile y, x
		1: return VisualShaderNode.PORT_TYPE_SCALAR #zoom
		2: return VisualShaderNode.PORT_TYPE_SCALAR #radians
		3: return VisualShaderNode.PORT_TYPE_SCALAR #float
		
func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "UV"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_2D

func _get_global_code(mode):
	#{LIB_rot}
	return """

	{LIB_rand}
	""".format({
		"LIB_rot":LSL.vec2_rotate,
		"LIB_rand":LSL.random_float
		})

func _get_code(input_vars, output_vars, mode, type):
	var do_rot
	do_rot = """
	//From Arnklit
	//vec2 unique_val = floor(st * {zoom}) / {zoom}; 
	vec2 unique_val = floor( UV.xy/{in_tilexy}.xy * {in_tilexy}.x) / {in_tilexy}.x;
	float rand_rotation = (random_float(unique_val) * 2.0 - 1.0) * {rr} * 3.14;
	//float rand_rotation = (random_float(unique_val)) * {rr};// * 3.14;
	rand_rotation += {rot};
	st = vec2_rotate(st, rand_rotation);
	
	""".format({
		"rot":	input_vars[2],
		"rr":	input_vars[3]
		})

	#do_rot = "st = vec2_rotate(st, %s);" % input_vars[2]
	
	var foo = """
	vec2 st = UV.xy/{in_tilexy}.xy;
	st = fract(st*{zoom}); //basic tile
	{do_rot}
	{out_uv} = st;
	""".format(
		{
		"do_rot": 	do_rot,
		"out_uv":	output_vars[0] 
		})
	foo = foo.format(
		{
		"in_tilexy":input_vars[0],
		"zoom":  	input_vars[1],
		})
	#print(foo) 
	return foo
