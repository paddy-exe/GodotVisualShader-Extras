# The MIT License
# Copyright © 2022 Inigo Quilez
# Copyright (c) 2018-2021 Rodolphe Suescun and contributors
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
class_name VisualShaderNodeCustomCompare

func _get_name():
	return "Compare"

func _init() -> void:
	pass#set_input_port_default_value(2, 0.5)

func _get_category():
	return "VisualShaderExtras/Usability"

func _get_description():
	return "Compare Color inputs and output a mask for the second input"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 2

func _get_input_port_name(port):
	match port:
		0:
			return "Color 1"
		1:
			return "Color 2"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_4D
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "Mask"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR #float

func _get_global_code(mode):
	## Code from MaterialMaker, care of Rodzilla
	return """
		float compare(vec4 in1, vec4 in2) 
		{
			return dot(abs(in1-in2), vec4(1.0));
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	return "%s = compare(%s,%s);" % [output_vars[0],input_vars[0],input_vars[1]]
