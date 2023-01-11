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
class_name TempVisualShaderNodeConverter

func _get_name():
	return "Converter"

func _get_category():
	return "VisualShaderExtras/Usability"

func _get_description():
	return "Lets you convert number-like things into specific types. Passes through UV and Transforms."

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

const names:Array = [
	["UV", 			VisualShaderNode.PORT_TYPE_VECTOR_2D],
	["Transform", 	VisualShaderNode.PORT_TYPE_TRANSFORM],
	["Bool", 		VisualShaderNode.PORT_TYPE_BOOLEAN],
	["Integer", 	VisualShaderNode.PORT_TYPE_SCALAR_INT],
	["Float", 		VisualShaderNode.PORT_TYPE_SCALAR],
	["Vec2D", 		VisualShaderNode.PORT_TYPE_VECTOR_2D],
	["Vec3D", 		VisualShaderNode.PORT_TYPE_VECTOR_3D],
	["Vec4D", 		VisualShaderNode.PORT_TYPE_VECTOR_4D],
]
enum {UV, XFORM, ANY_NUMBERLIKE}
enum {Z0, Z1, BOOL, INT, FLOAT, VEC2, VEC3, VEC4}
const in_ports := [UV,XFORM,ANY_NUMBERLIKE]
const out_ports: = [0,1,BOOL,INT,FLOAT,VEC2,VEC3,VEC4]

func _get_output_port_count():
	return out_ports.size()

func _get_output_port_type(port:int):
	return names[port][1]

func _get_output_port_name(port: int):
	if port > 1:
		return names[port][0]
	return ""
	
func _get_input_port_count():
	return in_ports.size()

func _get_input_port_name(port):
	if port in in_ports:
		## Boolean input is the one that gets any number-like plugged in
		## All the conversions happen from this pov.
		if port == ANY_NUMBERLIKE:
			return "Number-like To:"
		return names[port][0]

func _get_input_port_type(port):
	if port in in_ports:
		return names[port][1]

## A brutal way to work out what the variable name is
## and infer its type from the input_vars array.
func _get_input_port_var_and_its_type(inp:String)->Array:
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
	# go thru all the input vars
	for p in range(UV,input_vars.size()):
		var inp : String = input_vars[p]
		if inp: #if there is input on the input port
			# Handle the first two pass-throughs
			var out = output_vars[p]
			match p:
				UV:
					s += "{out} = {inp};\n".format({"out":out,"inp":inp}) 
				XFORM:
					s += "{out} = {inp};\n".format({"out":out,"inp":inp})
					
				## Then handle the conversions
				ANY_NUMBERLIKE:
					# bool seems to sort itself out
					s += "{out} = {inp};\n".format({"out":out,"inp":inp}) 
					
					# the other need more brute-force
					var var_type:Array = _get_input_port_var_and_its_type(inp)
					var in_type:String = var_type[1]
					
					# go thru each of the outputs from INT down to VEC4
					# and try to assign logical outputs to them from the 
					# given input type.
					for out_port in range(INT, output_vars.size()):
						out = output_vars[out_port]
						match names[out_port][1]: #match GOINT OUT TO
							VisualShaderNode.PORT_TYPE_SCALAR:
								match in_type: #match COMING IN FROM
									"bool": s += "{out} = {name} ? 1.0 : 0.0;"
									"int":  s += "{out} = float({name});"
									"float":s += "{out} = {name};"
									"vec2": s += "{out} = float({name}.x);"
									"vec3": s += "{out} = float({name}.x);"
									"vec4": s += "{out} = float({name}.x);"
							VisualShaderNode.PORT_TYPE_SCALAR_INT:
								match in_type:
									"bool": s += "{out} = {name} ? 1 : 0;"
									"int":  s += "{out} = {name};"
									"float":s += "{out} = int({name});"
									"vec2": s += "{out} = int({name}.x);"
									"vec3": s += "{out} = int({name}.x);"
									"vec4": s += "{out} = int({name}.x);"
							VisualShaderNode.PORT_TYPE_VECTOR_2D:
								match in_type:
									"bool": s += "{out} = vec2({name} ? 1.0 : 0.0);"
									"int":  s += "{out} = vec2(float({name}));"
									"float":s += "{out} = vec2(float({name}));"
									"vec2": s += "{out} = {name};"
									"vec3": s += "{out} = vec2({name}.xy);"
									"vec4": s += "{out} = vec2({name}.xy);"
							VisualShaderNode.PORT_TYPE_VECTOR_3D:
								match in_type:
									"bool": s += "{out} = vec3({name} ? 1.0 : 0.0);"
									"int":  s += "{out} = vec3(float({name}));"
									"float":s += "{out} = vec3(float({name}));"
									"vec2": s += "{out} = vec3({name}.xy, 0.);"
									"vec3": s += "{out} = {name};"
									"vec4": s += "{out} = vec3({name}.xyz);"
							VisualShaderNode.PORT_TYPE_VECTOR_4D:
								match in_type:
									"bool": s += "{out} = vec4({name} ? 1.0 : 0.0);"
									"int":  s += "{out} = vec4(float({name}));"
									"float":s += "{out} = vec4(float({name}));"
									"vec2": s += "{out} = vec4({name}.xy,0.,0.);"
									"vec3": s += "{out} = vec4({name}.xyz,0.);"
									"vec4": s += "{out} = {name};"
						s = s.format({"out":out,"name":var_type[0]}) + "\n"
	return s
