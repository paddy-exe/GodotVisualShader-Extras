tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeUVPolarCoord

func _init():
	set_input_port_default_value(1, Vector3(0.5,0.5,0))
	set_input_port_default_value(2, 1)
	set_input_port_default_value(3, 1)

func _get_name():
	return "UVPolarCoord"

func _get_category():
	return "VisualShaderExtras"

func _get_subcategory():
	return "UV"

func _get_description():
	return "UV to Polar Coordinates"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count():
	return 4

func _get_input_port_name(port):
	match port:
		0:
			return "uv"
		1:
			return "center"
		2:
			return "zoom strength"
		3:
			return "repeat"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "uv"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode):
	if (mode == Shader.MODE_SPATIAL):
		return """
			vec2 uv_polarcoord_spatial(vec2 __uv, vec2 __center, float __zoom, float __repeat)
			{
				vec2 __dir = __uv - __center;
				float __radius = length(__dir) * 2.0;
				float __angle = atan(__dir.y, __dir.x) * 1.0/(3.1415 * 2.0);
				return vec2(__radius * __zoom, __angle * __repeat);
			}
		"""
	elif (mode == Shader.MODE_CANVAS_ITEM):
		return """
			vec2 uv_polarcoord_canvas(vec2 __uv, vec2 __center, float __zoom, float __repeat)
			{
				vec2 __dir = __uv - __center;
				float __radius = length(__dir) * 2.0;
				float __angle = atan(__dir.y, __dir.x) * 1.0/(3.1415 * 2.0);
				return mod(vec2(__radius * __zoom, __angle * __repeat), 1.0);
			}
	"""

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	
	if input_vars[0]:
		uv = input_vars[0]	
	
	if (mode == Shader.MODE_CANVAS_ITEM):
		return "%s.xy = uv_polarcoord_canvas(%s.xy, %s.xy, %s, %s);" % [output_vars[0], uv, input_vars[1], input_vars[2], input_vars[3]]
	elif (mode == Shader.MODE_SPATIAL):
		return "%s.xy = uv_polarcoord_spatial(%s.xy, %s.xy, %s, %s);" % [output_vars[0], uv, input_vars[1], input_vars[2], input_vars[3]]
