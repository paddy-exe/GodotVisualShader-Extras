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

@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeReroute

func _get_name():
	return "Reroute"

func _get_category():
	return "VisualShaderExtras/Usability"

func _get_description():
	return "Re-route any number-like. Helps with long noodles.\nWill convert the incoming to the outgoing it connects to. You can't reroute Transforms."

#func _get_return_icon_type():
#	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_output_port_count():
	return 1

func _get_output_port_type(port:int):
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_output_port_name(port: int):
	return ""
	
func _get_input_port_count():
	return 1

func _get_input_port_name(port):
	return ""

func _get_input_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_code(input_vars, output_vars, mode, type):
	if input_vars[0]:
		return "%s = %s;\n" % [output_vars[0],input_vars[0]]

