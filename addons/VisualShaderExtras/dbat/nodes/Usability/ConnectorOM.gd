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
class_name TempVisualShaderNodeOneToMany

func _get_name():
	return "ConnectOne"

func _get_category():
	return "VisualShaderExtras/Usability"

func _get_description():
	return "Pass any number-like out the other side. Helps with long noodles.\nWill convert the incoming to the outgoing that the out noodles connect to."

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_output_port_count():
	return 1

## We will always use a Vec4 as the output type
## and convert input to fit.
func _get_output_port_type(port:int):
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_output_port_name(port: int):
	return ""
	
func _get_input_port_count():
	return 1

func _get_input_port_name(port):
	return ""

func _get_input_port_type(port):
	return VisualShaderNode.PORT_TYPE_BOOLEAN

## A brutal way to work out what the variable name is
## and infer its type from the input_vars array.
## NOTE: If the Godot source code changes even a space
## character then this will break.
func _get_input_port_varname_and_type(inp:String)->Array:
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
	
func _get_code(input_vars, output_vars, mode, type):
	var s := ""
	var inp : String = input_vars[0]
	if inp: #if there is input on the input port
		var out = output_vars[0]
		
		# Work out the actual incoming type
		var var_type:Array = _get_input_port_varname_and_type(inp)
		var in_type:String = var_type[1]
		
		# Go thru each of the outputs from INT down to VEC4
		# and try to assign logical outputs to them from the 
		# given input type.
		out = output_vars[0]
		match in_type:
			"bool": s += "{out} = vec4({name} ? 1.0 : 0.0);"
			"int":  s += "{out} = vec4(float({name}));"
			"float":s += "{out} = vec4(float({name}));"
			"vec2": s += "{out} = vec4({name}.xy,0.,0.);"
			"vec3": s += "{out} = vec4({name}.xyz,0.);"
			"vec4": s += "{out} = {name};"
		s = s.format({"out":out,"name":var_type[0]}) + "\n"
	return s
