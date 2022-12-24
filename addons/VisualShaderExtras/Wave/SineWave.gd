@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeSineWave

func _init():
	set_input_port_default_value(1, 1.0)
	set_input_port_default_value(2, 1.0)
	set_input_port_default_value(3, 0.0)
	set_input_port_default_value(4, 0.0)

func _get_name():
	return "SineWave"

func _get_category():
	return "VisualShaderExtras/Wave"

func _get_description():
	return "Sine Wave function"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 5

func _get_input_port_name(port):
	match port:
		0:
			return "IN"
		1:
			return "Amplitude"
		2:
			return "Frequency"
		3:
			return "Phase"
		4:
			return "Height"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR
		4:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return ""

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return """
		float sine_wave(float IN, float __amplitude, float __frequency, float __phase, float __height) {
			return __amplitude * sin(2.0 * PI * __frequency * IN + __phase) + __height;
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	
	return "%s = sine_wave(%s, %s, %s, %s, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2], input_vars[3], input_vars[4]]
