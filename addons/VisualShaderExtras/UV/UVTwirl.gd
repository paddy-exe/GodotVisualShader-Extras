tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeUVTwirl

func _init():
	set_input_port_default_value(1, Vector3(0.5,0.5,0))
	set_input_port_default_value(2, 10)
	set_input_port_default_value(3, Vector3(0,0,0))

func _get_name():
	return "UVTwirl"

func _get_category():
	return "VisualShaderExtras"

func _get_subcategory():
	return "UV"

func _get_description():
	return "UV Twirl"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR


func _get_input_port_count():
	return 4

func _get_input_port_name(port):
	match port:
		0:
			return "uv"
		1:
			return "Center"
		2:
			return "Strength"
		3:
			return "Offset"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "Twirl UV"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode):
	return """
		vec2 Twirl(vec2 __uv, vec2 __center, float __strength, vec2 __offset)
		{
			vec2 __delta = __uv - __center;
			float __angle = __strength * length(__delta);
			float __x = cos(__angle) * __delta.x - sin(__angle) * __delta.y;
			float __y = sin(__angle) * __delta.x + cos(__angle) * __delta.y;
			return vec2(__x + __center.x + __offset.x, __y + __center.y + __offset.y);
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	
	if input_vars[0]:
		uv = input_vars[0]
	
	return "%s.xy = Twirl(%s.xy, %s.xy, %s, %s.xy);" % [output_vars[0], uv, input_vars[1], input_vars[2], input_vars[3]]
