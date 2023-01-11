## TOTAL FAIL
##
## Tried to make a single in ---> out connector that changed the 
## in and out ports dynamically. No way in hell.



## The MIT License
## Copyright © 2022 Donn Ingle (on shoulders of giants)
## Permission is hereby granted, free of charge, to any person obtaining a copy 
## of this software and associated documentation files (the "Software"), 
## to deal in the Software without restriction, including without limitation 
## the rights to use, copy, modify, merge, publish, distribute, sublicense, 
## and/or sell copies of the Software, and to permit persons to whom the 
## Software is furnished to do so, subject to the following conditions: 
## The above copyright notice and this permission notice shall be included 
## in all copies or substantial portions of the Software. 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
## EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
## MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
## IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
## DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
## TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
## OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#@tool
#extends VisualShaderNodeCustom
#class_name TempVisualShaderNodeConnector2
#
#func _init():
#	actual_in_type = null
#	self.connect("editor_refresh_request",self._on_changed)
#
#func _get_name():
#	return "Connector2"
#
#func _get_version():
#	return "1"
#
#func _get_category():
#	return "VisualShaderExtras/Usability"
#
#func _get_description():
#	return LizardShaderLibrary.format_description(self,
#	"Node to let you just hang a noodle somewhere, and pass it through.\nNB: Make sure to match the same in and out ports.\nNote: One can't connect any Sampler.")
#
#func _get_return_icon_type():
#	return VisualShaderNode.PORT_TYPE_VECTOR_4D
#
#const ptypes:={
#	VisualShaderNode.PORT_TYPE_BOOLEAN:VisualShaderNode.PORT_TYPE_BOOLEAN,
#	VisualShaderNode.PORT_TYPE_SCALAR_INT:VisualShaderNode.PORT_TYPE_SCALAR_INT,
#	VisualShaderNode.PORT_TYPE_SCALAR:VisualShaderNode.PORT_TYPE_SCALAR,
#	VisualShaderNode.PORT_TYPE_VECTOR_2D:VisualShaderNode.PORT_TYPE_VECTOR_2D,
#	VisualShaderNode.PORT_TYPE_VECTOR_3D:VisualShaderNode.PORT_TYPE_VECTOR_3D,
#	VisualShaderNode.PORT_TYPE_VECTOR_4D:VisualShaderNode.PORT_TYPE_VECTOR_4D,
#}
##const names:Array = ["Boolean","Scalar","Integer","Vector2D","Vector3D","Vector4D","Transform"]
#
#
#@export var actual_in_type = null
#
#func _get_output_port_count():
#	return 1
#
#func _on_changed():
#	print("CHANGED")
#	_get_output_port_type(0) 
#
#func _get_output_port_type(port):
#	return actual_in_type
#
#func _get_input_port_type(port):
#	return VisualShaderNode.PORT_TYPE_BOOLEAN
#
#func _get_output_port_name(port: int):
#	return "OUT"
#
#func _get_input_port_count():
#	return 1
#
#func _get_input_port_name(port):
#	return "Anything"
#
### A brutal way to work out what the variable name is
### and infer its type from the input_vars array.
#func _get_input_port_var_and_its_type(inp:String)->Array:
#	print("inp:",inp)
#	#inp:... = LOOKFORME > 0 ? true : false --> int
#	if inp.contains(" > 0 ?"):
#		return [inp.replace(" > 0 ? true : false",""), ptypes[VisualShaderNode.PORT_TYPE_SCALAR_INT]]  
#	#inp:... = LOOKFORME > 0.0 ? true : false --> float/scalar
#	if inp.contains(" > 0.0"):
#		return [inp.replace(" > 0.0 ? true : false",""), ptypes[VisualShaderNode.PORT_TYPE_SCALAR]]
#	# inp:... = all(bvec2(LOOKFORME)); -> vec2
#	if inp.contains("all(bvec2"):
#		return [inp.replace("all(bvec2(","").replace("))",""), ptypes[VisualShaderNode.PORT_TYPE_VECTOR_2D]]
#	# inp:... = all(bvec3(LOOKFORME)); -> vec3
#	if inp.contains("all(bvec3"):
#		return [inp.replace("all(bvec3(","").replace("))",""), ptypes[VisualShaderNode.PORT_TYPE_VECTOR_3D]]
#	# inp:... = all(bvec4(LOOKFORME)); -> vec4
#	if inp.contains("all(bvec4"):
#		return [inp.replace("all(bvec4(","").replace("))",""), ptypes[VisualShaderNode.PORT_TYPE_VECTOR_4D]] 
#
#	return [inp,ptypes[VisualShaderNode.PORT_TYPE_BOOLEAN]] #boolean is the last
#
#var foo = true
#var in_vars:Array 
#
#
#
#func _get_code(input_vars, output_vars, mode, type):
#	var data := _get_input_port_var_and_its_type(input_vars[0])
#	var new_actual_in_type = data[1] 
#
#	if new_actual_in_type != actual_in_type:
#		actual_in_type = new_actual_in_type
#		print("REDIONG")
#		#emit_signal("editor_refresh_request")
##		var junk = _get_code(input_vars, output_vars, mode, type)
#		#var junk = _get_code(
#		print("====",junk,"====")
#	var s:String=""
#	var out = output_vars[0]
#	var inp : String = input_vars[0]
#	# bool seems to sort itself out
#	s += "{out} = {inp};\n".format({"out":out,"inp":inp}) 
#
#	# the other need more brute-force
#	#var var_type:Array = _get_input_port_var_and_its_type(inp)
#	var in_type = actual_in_type
#
#	# go thru each of the outputs from INT down to VEC4
#	# and try to assign logical outputs to them from the 
#	# given input type.
#	#for out_port in range(0, 1):
#	out = output_vars[0]
#	match actual_in_type: #match GOINT OUT TO
#		VisualShaderNode.PORT_TYPE_SCALAR:
#			match in_type: #match COMING IN FROM
#				VisualShaderNode.PORT_TYPE_BOOLEAN: s += "{out} = {name} ? 1.0 : 0.0;"
#				VisualShaderNode.PORT_TYPE_SCALAR_INT:  s += "{out} = float({name});"
#				VisualShaderNode.PORT_TYPE_SCALAR:s += "{out} = {name};"
#				VisualShaderNode.PORT_TYPE_VECTOR_2D: s += "{out} = float({name}.x);"
#				VisualShaderNode.PORT_TYPE_VECTOR_3D: s += "{out} = float({name}.x);"
#				VisualShaderNode.PORT_TYPE_VECTOR_4D: s += "{out} = float({name}.x);"
#		VisualShaderNode.PORT_TYPE_SCALAR_INT:
#			match in_type:
#				VisualShaderNode.PORT_TYPE_BOOLEAN: s += "{out} = {name} ? 1 : 0;"
#				VisualShaderNode.PORT_TYPE_SCALAR_INT:  s += "{out} = {name};"
#				VisualShaderNode.PORT_TYPE_SCALAR:s += "{out} = int({name});"
#				VisualShaderNode.PORT_TYPE_VECTOR_2D: s += "{out} = int({name}.x);"
#				VisualShaderNode.PORT_TYPE_VECTOR_3D: s += "{out} = int({name}.x);"
#				VisualShaderNode.PORT_TYPE_VECTOR_4D: s += "{out} = int({name}.x);"
#		VisualShaderNode.PORT_TYPE_VECTOR_2D:
#			match in_type:
#				VisualShaderNode.PORT_TYPE_BOOLEAN: s += "{out} = vec2({name} ? 1.0 : 0.0);"
#				VisualShaderNode.PORT_TYPE_SCALAR_INT:  s += "{out} = vec2(float({name}));"
#				VisualShaderNode.PORT_TYPE_SCALAR:s += "{out} = vec2(float({name}));"
#				VisualShaderNode.PORT_TYPE_VECTOR_2D: s += "{out} = {name};"
#				VisualShaderNode.PORT_TYPE_VECTOR_3D: s += "{out} = vec2({name}.xy);"
#				VisualShaderNode.PORT_TYPE_VECTOR_4D: s += "{out} = vec2({name}.xy);"
#		VisualShaderNode.PORT_TYPE_VECTOR_3D:
#			match in_type:
#				VisualShaderNode.PORT_TYPE_BOOLEAN: s += "{out} = vec3({name} ? 1.0 : 0.0);"
#				VisualShaderNode.PORT_TYPE_SCALAR_INT:  s += "{out} = vec3(float({name}));"
#				VisualShaderNode.PORT_TYPE_SCALAR:s += "{out} = vec3(float({name}));"
#				VisualShaderNode.PORT_TYPE_VECTOR_2D: s += "{out} = vec3({name}.xy, 0.);"
#				VisualShaderNode.PORT_TYPE_VECTOR_3D: s += "{out} = {name};"
#				VisualShaderNode.PORT_TYPE_VECTOR_4D: s += "{out} = vec3({name}.xyz);"
#		VisualShaderNode.PORT_TYPE_VECTOR_4D:
#			match in_type:
#				VisualShaderNode.PORT_TYPE_BOOLEAN: s += "{out} = vec4({name} ? 1.0 : 0.0);"
#				VisualShaderNode.PORT_TYPE_SCALAR_INT:  s += "{out} = vec4(float({name}));"
#				VisualShaderNode.PORT_TYPE_SCALAR:s += "{out} = vec4(float({name}));"
#				VisualShaderNode.PORT_TYPE_VECTOR_2D: s += "{out} = vec4({name}.xy,0.,0.);"
#				VisualShaderNode.PORT_TYPE_VECTOR_3D: s += "{out} = vec4({name}.xyz,0.);"
#				VisualShaderNode.PORT_TYPE_VECTOR_4D: s += "{out} = {name};"
#	s = s.format({"out":out,"name":data[0]}) + "\n"
#
#	print(s)
#	return s
#
#
#
#	#last_in_type = _get_input_port_type(0)
#	print("input:", input_vars, " output:", output_vars, " act it:", actual_in_type)
#	return "{out} = {in};".format({"out":output_vars[0], "in":input_vars[0]})
