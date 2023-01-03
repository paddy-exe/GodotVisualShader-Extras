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
class_name TempVisualShaderNodeConnector

func _get_name():
	return "Connector"

func _get_version():
	return "1"
	
func _get_category():
	return "VisualShaderExtras/Usability"

func _get_description():
	return LizardShaderLibrary.format_description(self,
	"Node to let you just hang a noodle somewhere, and pass it through.\nNB: Make sure to match the same in and out ports.")

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

const ptypes:Array = [
	VisualShaderNode.PORT_TYPE_BOOLEAN,
	VisualShaderNode.PORT_TYPE_SAMPLER,
	VisualShaderNode.PORT_TYPE_SCALAR,
	VisualShaderNode.PORT_TYPE_SCALAR_INT,
	VisualShaderNode.PORT_TYPE_TRANSFORM,
	VisualShaderNode.PORT_TYPE_VECTOR_2D,
	VisualShaderNode.PORT_TYPE_VECTOR_3D,
	VisualShaderNode.PORT_TYPE_VECTOR_4D
]
const names:Array = ["B","S","Flt","Int","X","2D","3D","4D"]
func _get_output_port_type(port):
	return ptypes[port]
	
func _get_output_port_count():
	return 8

func _get_output_port_name(port: int):
	return names[port]
	
func _get_input_port_count():
	return 8

func _get_input_port_name(port):
	return names[port]

func _get_input_port_type(port):
	return ptypes[port]

func _get_code(input_vars, output_vars, mode, type):
	var s = ""
	for p in range(0,8):
		if input_vars[p]:
			s += "{outp} = {inp};".format({"outp":output_vars[p],"inp":input_vars[p]})
	return s
	
## Sadly there is no way to know whether an output port
## is actually connected to a noodle - hence I can't make this
## into a general type casting control :(
## I leave this code for possible futures:
#	var in_list:Array = input_vars.duplicate()
#	var out_list:Array = output_vars.duplicate()
#
#	for in_v in in_list:
#		if in_v:
#			print("in_v:", in_v)
#			var i = 0
#			for out_v in out_list:
#				print("out_v:", out_v)
#				if out_v:
#					s += "{out_v} = {in_v};\n".format({"out_v":out_v,"in_v":in_v})
#					out_list[i] = ""
#				i += 1
#	return s
