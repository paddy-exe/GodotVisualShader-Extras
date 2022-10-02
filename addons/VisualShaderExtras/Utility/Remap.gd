tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeRemap

func _init():
	set_input_port_default_value(1, 0)
	set_input_port_default_value(2, 1)
	set_input_port_default_value(3, 0)
	set_input_port_default_value(4, 1)

func _get_name():
	return "Remap"

func _get_category():
	return "VisualShaderExtras"

func _get_subcategory():
	return "Utility"

func _get_description():
	return "Remapping values"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count():
	return 5

func _get_input_port_name(port):
	match port:
		0:
			return "value"
		1:
			return "input min"
		2:
			return "input max"
		3:
			return "output min"
		4:
			return "output max"

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

func _get_output_port_name(port: int) -> String:
	return "value"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode):
	return """
		float remap_value(float __value, float __input_min, float __input_max, float __output_min, float __output_max) {
			float _input_range = __input_max - __input_min;
			float _output_range = __output_max - __output_min;
			return __output_min + _output_range * ((__value - __input_min) / _input_range);
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	
	return "%s = remap_value(%s, %s, %s, %s, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2], input_vars[3], input_vars[4]]
