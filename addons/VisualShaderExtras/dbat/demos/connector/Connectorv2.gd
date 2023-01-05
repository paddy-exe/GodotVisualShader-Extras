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
class_name TempVisualShaderNodeConnector2

func _init():
	in_type = "vec4"
	
func _get_name():
	return "Connector2"

func _get_version():
	return "1"
	
func _get_category():
	return "VisualShaderExtras/Usability"

func _get_description():
	return LizardShaderLibrary.format_description(self,
	"Node to let you just hang a noodle somewhere, and pass it through.\nNB: Make sure to match the same in and out ports.\nNote: One can't connect any Sampler.")

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

const ptypes:={
	"bool":VisualShaderNode.PORT_TYPE_BOOLEAN,
	"int":VisualShaderNode.PORT_TYPE_SCALAR_INT,
	"float":VisualShaderNode.PORT_TYPE_SCALAR,
	"vec2":VisualShaderNode.PORT_TYPE_VECTOR_2D,
	"vec3":VisualShaderNode.PORT_TYPE_VECTOR_3D,
	"vec4":VisualShaderNode.PORT_TYPE_VECTOR_4D,
}
#const names:Array = ["Boolean","Scalar","Integer","Vector2D","Vector3D","Vector4D","Transform"]


var in_type : String

func _get_output_port_count():
	return 1

func _get_output_port_type(port):
	var outpt = ptypes[in_type]
	if last_pt != outpt:
		last_pt = outpt
	return outpt

func _get_input_port_type(port):
	var inpt = ptypes[in_type]
	if inpt != last_pt:
		last_pt = inpt
	return last_pt 

func _get_output_port_name(port: int):
	return "OUT"

func _get_input_port_count():
	return 1

func _get_input_port_name(port):
	return "Anything"

## A brutal way to work out what the variable name is
## and infer its type from the input_vars array.
func _get_input_port_var_and_its_type(inp:String)->Array:
	print("inp:",inp)
	#inp:... = LOOKFORME > 0 ? true : false --> int
	if inp.contains(" > 0 ?"):
		return [inp.replace(" > 0 ? true : false",""), "int"]  
	#inp:... = LOOKFORME > 0.0 ? true : false --> float/scalar
	if inp.contains(" > 0.0"):
		return [inp.replace(" > 0.0 ? true : false",""), "float"]
	# inp:... = all(bvec2(LOOKFORME)); -> vec2
	if inp.contains("all(bvec2"):
		return [inp.replace("all(bvec2(","").replace("))",""), "vec2"]
	# inp:... = all(bvec3(LOOKFORME)); -> vec3
	if inp.contains("all(bvec3"):
		return [inp.replace("all(bvec3(","").replace("))",""), "vec3"]
	# inp:... = all(bvec4(LOOKFORME)); -> vec4
	if inp.contains("all(bvec4"):
		return [inp.replace("all(bvec4(","").replace("))",""), "vec4"] 
	
	return [inp,"bool"] #boolean is the last

var foo = true
var in_vars:Array
var last_pt
func _get_code(input_vars, output_vars, mode, type):
	var data := _get_input_port_var_and_its_type(input_vars[0])
	in_type = data[1]  
	
	last_pt = _get_input_port_type(0)
 
	return "{out} = {in};".format({"out":output_vars[0], "in":input_vars[0]})
