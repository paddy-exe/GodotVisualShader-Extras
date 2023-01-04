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
	in_type = "bool"
	
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
	return VisualShaderNode.PORT_TYPE_BOOLEAN

const ptypes:={
	"bool":VisualShaderNode.PORT_TYPE_BOOLEAN,
	"int":VisualShaderNode.PORT_TYPE_SCALAR_INT,
	"float":VisualShaderNode.PORT_TYPE_SCALAR,
	"vec2":VisualShaderNode.PORT_TYPE_VECTOR_2D,
	"vec3":VisualShaderNode.PORT_TYPE_VECTOR_3D,
	"vec4":VisualShaderNode.PORT_TYPE_VECTOR_4D,
}
#const names:Array = ["Boolean","Scalar","Integer","Vector2D","Vector3D","Vector4D","Transform"]

var in_name : String
var in_type : String

func _get_output_port_count():

	return 1

func _get_output_port_type(port):
	print("GET OUT TYPE RUNS")


	return ptypes[in_type] 

func _get_output_port_name(port: int):
	return "OUT"#in_name
	
	
func _get_input_port_count():
	return 1

func _get_input_port_name(port):
	return "Anything"

func _get_input_port_type(port):
	#var outpt = ptypes[in_type]#self._get_input_port_type(0)
		#emit_changed()
		#last_pt = outpt
	return last_pt


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

#func _get_global_code(mode):
#	var outpt = self._get_output_port_type(0)
#	return """
#	vec3 vec3thru = vec3(0.);
#	vec4 vec4thru;
#	"""
	
var foo = true
var in_vars:Array
var last_pt
func _get_code(input_vars, output_vars, mode, type):
	#call_deferred("emit_changed")
	var data := _get_input_port_var_and_its_type(input_vars[0])
	#print ("data:",data) 
	in_name = data[0]
	in_type = data[1]
	
	last_pt = _get_input_port_type(0)

		
#	if foo:
#		foo = false
#		self.editor_refresh_request.emit()
#		self._get_code(input_vars, output_vars, mode, type)
		
#	print("GET CODE")
#	in_vars = input_vars

	#print("in_name:",in_name)
#
#	print("outpt:",outpt)
	#print(output_vars)
#	#self._get_output_port_name(0)
	#foo = true
	#var s:String=""
#	s = "%s outpop = %s;" % [in_type, in_name]
	#s = "%sthru = %s;" % [in_type, in_name]
	return "{out} = {in};".format({"out":output_vars[0], "in":input_vars[0]})#in_name})
#	var s = ""
#	for p in range(0,7):
#		if input_vars[p]:
#			s += "{outp} = {inp};\n".format({"outp":output_vars[p],"inp":input_vars[p]})
#	return s

## I learned that we can't use Sampers in the normal way as other types
## they can only be declared in global space with uniform sampler2d
## So I took that out of the connector.

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
