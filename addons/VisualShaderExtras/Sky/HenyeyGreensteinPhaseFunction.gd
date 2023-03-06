# Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md).
# Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.                 
#
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the       
# "Software"), to deal in the Software without restriction, including   
# without limitation the rights to use, copy, modify, merge, publish,   
# distribute, sublicense, and/or sell copies of the Software, and to    
# permit persons to whom the Software is furnished to do so, subject to 
# the following conditions:                                             
#
# The above copyright notice and this permission notice shall be        
# included in all copies or substantial portions of the Software.       
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeHenyeyGreensteinPhase

func _get_name():
	return "HenyeyGreensteinPhaseSimpl"

func _init() -> void:
	set_input_port_default_value(1, 0.0)

func _get_category():
	return "VisualShaderExtras/Sky"

func _get_description():
	return """
		A phase function scattering an incoming ray in a specific direction (forward, isotropic or backword scattering).
		The algorithm is simplified for performance reasons. The scattering coefficient g stays between -1 and 1.
	"""

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 2

func _get_input_port_name(port):
	match port:
		0:
			return "Angle"
		1:
			return "Scattering coefficient"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "Scattered Angle"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return """
		float henyey_greenstein(float cos_theta, float g) {
			const float k = 0.0795774715459;
			return k * (1.0 - g * g) / (pow(1.0 + g * g - 2.0 * g * cos_theta, 1.5));
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	return "%s.xy = henyey_greenstein(%s, %s);" % [output_vars[0], input_vars[0], input_vars[1]]
