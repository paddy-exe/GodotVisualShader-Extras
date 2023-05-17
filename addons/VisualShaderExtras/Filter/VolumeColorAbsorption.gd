@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeCustomVolumeColorAbsorption

func _get_name():
	return "VolumeColorAbsorption"

func _init() -> void:
	set_input_port_default_value(1, Vector4(0.7, 0.3, 0.4, 1.0))
	set_input_port_default_value(2, 0.5)
	set_input_port_default_value(3, 0.5)

func _get_category():
	return "VisualShaderExtras/Filter"

func _get_description():
	return """The absorption color is subtracted from the input color in the 
		ratio of the absorption coefficient and the absorption depth.
		This function can be used for a gradient depth effect in water shaders."""

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_input_port_count():
	return 4

func _get_input_port_name(port):
	match port:
		0:
			return "In"
		1:
			return "Absorption Color"
		2:
			return "Absorption Coefficient"
		3:
			return "Absorption Depth"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_4D
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR_4D
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "Out"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_global_code(mode):
	return """
		vec4 volume_absorption(vec4 input_col, vec4 abs_col, float abs_coeff, float abs_depth) {
			return input_col - (1.0 - exp(-abs_coeff * abs_depth)) * abs_col;
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	return "%s = volume_absorption(%s, %s, %s, %s);" % [output_vars[0],input_vars[0],input_vars[1], input_vars[2], input_vars[3]]
