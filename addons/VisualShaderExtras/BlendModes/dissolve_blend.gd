# MIT License
#
# Copyright (c) 2018-2021 Rodolphe Suescun and contributors
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

# Godot license
#/**************************************************************************/
#/* Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md). */
#/* Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.                  */
#/*                                                                        */
#/* Permission is hereby granted, free of charge, to any person obtaining  */
#/* a copy of this software and associated documentation files (the        */
#/* "Software"), to deal in the Software without restriction, including    */
#/* without limitation the rights to use, copy, modify, merge, publish,    */
#/* distribute, sublicense, and/or sell copies of the Software, and to     */
#/* permit persons to whom the Software is furnished to do so, subject to  */
#/* the following conditions:                                              */
#/*                                                                        */
#/* The above copyright notice and this permission notice shall be         */
#/* included in all copies or substantial portions of the Software.        */
#/*                                                                        */
#/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
#/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
#/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
#/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
#/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
#/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
#/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
#/**************************************************************************/

@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeDissolveBlendAdvanced

func _get_name():
	return "BlendDissolve"

func _init() -> void:
	set_input_port_default_value(2, 0.5)
	set_input_port_default_value(3, Vector3(0.0, 0.0, 0.0))

func _get_category():
	return "VisualShaderExtras/BlendModes"

func _get_description():
	return "Dissolve Blending Mode"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_input_port_count():
	return 4

func _get_input_port_name(port):
	match port:
		0:
			return "Top layer"
		1:
			return "Bottom layer"
		2:
			return "Opacity"
		3:
			return "Noise Seed"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "Output"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_global_code(mode):
	return """
		// 3D Noise with friendly permission by Inigo Quilez
		vec3 hash_noise_range( vec3 p ) {
			p *= mat3(vec3(127.1, 311.7, -53.7), vec3(269.5, 183.3, 77.1), vec3(-301.7, 27.3, 215.3));
			return 2.0 * fract(fract(p)*4375.55) -1.;
		}

		float random_range(vec3 seed, float min, float max) {
			return mix(min, max, hash_noise_range(seed).x);
		}
		
		vec3 blend_dissolve(vec3 seed, vec3 c1, vec3 c2, float opacity) {
			if (random_range(vec3(seed), 0.0, 1.0) < opacity) {
				return c1;
			} else {
				return c2;
			}
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	
	return "%s.rgb = blend_dissolve(%s.rgb, %s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[3], input_vars[0], input_vars[1], input_vars[2]]
