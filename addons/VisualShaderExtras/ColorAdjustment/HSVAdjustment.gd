# Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md).
# Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
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

@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeCustomHSVAdjustment

func _get_name():
	return "HSVAdjustment"

func _init() -> void:
	set_input_port_default_value(1, 0.0)
	set_input_port_default_value(2, 0.0)
	set_input_port_default_value(3, 0.0)

func _get_category():
	return "VisualShaderExtras/ColorAdjustment"

func _get_description():
	return "Convert RGB input colors to HSV and offset their values"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_input_port_count():
	return 4

func _get_input_port_name(port):
	match port:
		0:
			return "RGB"
		1:
			return "Hue Offset (Degrees)"
		2:
			return "Saturation Offset"
		3:
			return "Value Offset"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "HSV"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_global_code(mode):
	return """
		vec3 hsv_adjustment(vec3 col, float hue_offset, float sat_offset, float val_offset) {
			vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			vec4 p = mix(vec4(col.bg, K.wz), vec4(col.gb, K.xy), step(col.b, col.g));
			vec4 q = mix(vec4(p.xyw, col.r), vec4(col.r, p.yzx), step(p.x, col.r));
			float d = q.x - min(q.w, q.y);
			float e = 1.0e-10;
			vec3 hsv = vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			hsv.x += hue_offset / 360.0;
			hsv.y += sat_offset;
			hsv.z += val_offset;
			return hsv;
		}
		
	"""

func _get_code(input_vars, output_vars, mode, type):
	return "%s = hsv_adjustment(%s.xyz, %s, %s, %s);" % [output_vars[0],input_vars[0],input_vars[1], input_vars[2], input_vars[3]]
