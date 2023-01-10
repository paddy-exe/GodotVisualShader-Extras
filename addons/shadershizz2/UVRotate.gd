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
class_name TEST2NodeUVRotate

var call_order:String = ""

func _get_name():
	if not "N" in call_order: call_order += "N"
	return "TESTUVRotate"

func _get_version():
	return "1"
	
func _get_category():
	return "VisualShaderExtras/TEST2"

func _get_description():
	return LizardShaderLibrary.format_description(self,
	"Rotates UV coordinates around a pivot point.")

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_2D

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_2D
	
func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "UV"
	
func _init() -> void:
	set_input_port_default_value(1, Vector2(0., 0.)) #pivot
	set_input_port_default_value(2, 0.0) #rot
	
func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0: return "UV"
		1: return "Pivot"
		2: return "Rotation (Radians)"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D #UV
		1: return VisualShaderNode.PORT_TYPE_VECTOR_2D #pivot
		2: return VisualShaderNode.PORT_TYPE_SCALAR #radians

func _get_global_func_names()->Array:
	return ["vec2_rotate"]

func _get_global_code(mode)->String:
	var gcode:String = ""
	gcode = ShaderFuncRef2.get_funcs(self)
	return gcode
	
func _get_code(input_vars, output_vars, mode, type):
	var uv = input_vars[0] if input_vars[0] else "UV"
	var code : String = """
	vec2 rotated_uv = {uv};
	rotated_uv = vec2_rotate({uv}, {rand_rotation}, {pivot});
	{out_uv} = rotated_uv;
	""".format(
		{
		"uv": uv,
		"pivot": input_vars[1],
		"rand_rotation": input_vars[2],
		"out_uv": output_vars[0] 
		})
	return _fix_funcs(code)

func _fix_funcs(code)->String:
	return ShaderFuncRef2.fix_funcs(self, code)
