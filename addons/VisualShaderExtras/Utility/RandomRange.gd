# Copyright (c) 2007-2022 Juan Linietsky, Ariel Manzur.
# Copyright (c) 2014-2022 Godot Engine contributors (cf. AUTHORS.md).
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeRandomRange

func _init():
	set_input_port_default_value(0, Vector3(1.0,1.0,1.0))
	set_input_port_default_value(1, 0.0)
	set_input_port_default_value(2, 1.0)

func _get_name():
	return "RandomRange"

func _get_category():
	return "VisualShaderExtras"

func _get_subcategory():
	return "Utility"

func _get_description():
	return "Random values between two ranges"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0:
			return "seed"
		1:
			return "min"
		2:
			return "max"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "value"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return """
		vec3 hash_noise_range( vec3 p ) {
			p *= mat3(vec3(127.1, 311.7, -53.7), vec3(269.5, 183.3, 77.1), vec3(-301.7, 27.3, 215.3));
			return 2.0 * fract(fract(p)*4375.55) -1.;
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	return "%s = mix(%s, %s, hash_noise_range(%s).x);" % [output_vars[0], input_vars[1], input_vars[2], input_vars[0]]
