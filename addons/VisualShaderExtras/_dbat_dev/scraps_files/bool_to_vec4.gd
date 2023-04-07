## A brutal way to work out what the variable name is
## and infer its type from the input_vars array.
## NOTE: If the Godot source code changes even a space
## character then this will break.
#func _get_input_port_varname_and_type(inp:String)->Array:
#	#inp:... = LOOKFORME > 0 ? true : false --> int
#	if inp.contains(" > 0 ?"):
#		return [inp.replace(" > 0 ? true : false",""), "int"]  
#	#inp:... = LOOKFORME > 0.0 ? true : false --> float/scalar
#	if inp.contains(" > 0.0"):
#		return [inp.replace(" > 0.0 ? true : false",""), "float"]
#	# inp:... = all(bvec2(LOOKFORME)); -> vec2
#	if inp.contains("all(bvec2"):
#		return [inp.replace("all(bvec2(","").replace("))",""), "vec2"]
#	# inp:... = all(bvec3(LOOKFORME)); -> vec3
#	if inp.contains("all(bvec3"):
#		return [inp.replace("all(bvec3(","").replace("))",""), "vec3"]
#	# inp:... = all(bvec4(LOOKFORME)); -> vec4
#	if inp.contains("all(bvec4"):
#		return [inp.replace("all(bvec4(","").replace("))",""), "vec4"] 
#
#	return [inp,"bool"] #boolean is the last
#
#func _get_code(input_vars, output_vars, mode, type):
#	var s := ""
#	var inp : String = input_vars[0]
#	if inp: #if there is input on the input port
#		var out = output_vars[0]
#
#		# Work out the actual incoming type
#		var var_type:Array = _get_input_port_varname_and_type(inp)
#		var in_type:String = var_type[1]
#
#		# Go thru each of the outputs from INT down to VEC4
#		# and try to assign logical outputs to them from the 
#		# given input type.
#		out = output_vars[0]
#		match in_type:
#			"bool": s += "{out} = vec4({name} ? 1.0 : 0.0);"
#			"int":  s += "{out} = vec4(float({name}));"
#			"float":s += "{out} = vec4(float({name}));"
#			"vec2": s += "{out} = vec4({name}.xy,0.,0.);"
#			"vec3": s += "{out} = vec4({name}.xyz,0.);"
#			"vec4": s += "{out} = {name};"
#		s = s.format({"out":out,"name":var_type[0]}) + "\n"
#	return s
