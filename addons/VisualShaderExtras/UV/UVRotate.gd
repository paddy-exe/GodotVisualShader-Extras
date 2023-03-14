@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeUVRotate

func _init():
	set_input_port_default_value(1, Vector2(0.5,0.5))
	set_input_port_default_value(2, 10.0)
	set_input_port_default_value(3, Vector2(0,0))

func _get_name():
	return "UVRotate"

func _get_category():
	return "VisualShaderExtras/UV"

func _get_description():
	return "UV Rotate"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_2D

func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0:
			return "UV"
		1:
			return "Pivot"
		2:
			return "Angle (Radians)"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "UV"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_2D

func _get_global_code(mode):
	return """
		vec2 uv_rotate(vec2 uv, vec2 pivot, float angle) {
			mat2 rotation = mat2(vec2(sin(angle), -cos(angle)), vec2(cos(angle), sin(angle)));
			uv -= pivot;
			uv = uv * rotation;
			uv += pivot;
			return uv;
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	
	if input_vars[0]:
		uv = input_vars[0]
	
	return "%s.xy = uv_rotate(%s.xy, %s.xy, %s);" % [output_vars[0], uv, input_vars[1], input_vars[2]]
