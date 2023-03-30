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
class_name VisualShaderNodeRerouteTransform

func _get_name():
	return "RerouteTransform"

func _get_category():
	return "VisualShaderExtras/Usability"

func _get_description():
	return "Node to let you just hang a noodle somewhere and pass it through.\nNB: Make sure to match the same in and out ports."

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_TRANSFORM

const ptypes:Array = [
	VisualShaderNode.PORT_TYPE_BOOLEAN,
	VisualShaderNode.PORT_TYPE_SCALAR,
	VisualShaderNode.PORT_TYPE_SCALAR_INT,
	VisualShaderNode.PORT_TYPE_VECTOR_2D,
	VisualShaderNode.PORT_TYPE_VECTOR_3D,
	VisualShaderNode.PORT_TYPE_VECTOR_4D,
	VisualShaderNode.PORT_TYPE_TRANSFORM,
	#VisualShaderNode.PORT_TYPE_SAMPLER #Does not seem to work in G 4.0.1
]
const names:Array = ["Boolean","Scalar","Integer","Vector2D","Vector3D","Vector4D","Transform"]#,"Sampler"]

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_TRANSFORM
	#return ptypes[port]
	
func _get_output_port_count():
	return 1 #ptypes.size()

func _get_output_port_name(port: int):
	return ""
	
func _get_input_port_count():
	return 1 #ptypes.size()

func _get_input_port_name(port):
	return "T"
	#return names[port]

func _get_input_port_type(port):
	return VisualShaderNode.PORT_TYPE_TRANSFORM
	#return ptypes[port]

func _get_code(input_vars, output_vars, mode, type):
	if input_vars[0]:
		return "%s = %s;\n" % [output_vars[0],input_vars[0]]
#	var s = ""
#	for p in range(0,7):
#		if input_vars[p]:
#			s += "{outp} = {inp};\n".format({"outp":output_vars[p],"inp":input_vars[p]})
#	return s
	
