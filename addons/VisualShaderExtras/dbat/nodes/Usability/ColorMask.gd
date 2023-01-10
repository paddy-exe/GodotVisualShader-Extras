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
class_name VisualShaderNodeCustomColorMask

func _init():
	set_input_port_default_value(2, 1.0)#blend amount
	
func _get_name():
	return "ColorMask"
	
func _get_category():
	return "VisualShaderExtras/Usability"

func _get_description():
	return "Compare Color inputs, and outputs a mask for the second input.\nAdded a Blend Amount to make the mask easier to control."

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR
	
func _get_output_port_count():
	return 1

func _get_output_port_name(port: int):
	return "Output"

func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0: return "Input"
		1: return "Mask Input"
		2: return "Blend Amount"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_4D
		1: return VisualShaderNode.PORT_TYPE_VECTOR_4D
		2: return VisualShaderNode.PORT_TYPE_SCALAR

## return all the functions (in the ShaderLib Dict) that you want
## to use.
func _get_global_func_names()->Array:
	return ["compare"]
	
func _get_global_code(mode):
	return ShaderLib.prep_global_code(self)

func _get_code(input_vars, output_vars, mode, type):
	var code = "%s = compare(%s,%s,%s);" % [output_vars[0],input_vars[0],input_vars[1],input_vars[2]]
	return ShaderLib.rename_functions(self, code)
