# based on this shadertoy source: https://www.shadertoy.com/view/XdS3RW
tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeExclusion

func _get_name():
	return "BlendExclusion"

func _get_category():
	return "VisualShaderExtras"

func _get_subcategory():
	return "BlendModes"

func _get_description():
	return "Exclusion Blending Mode"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count():
	return 2

func _get_input_port_name(port):
	match port:
		0:
			return "top layer"
		1:
			return "bottom layer"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "output"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode):
	return """
		vec3 exclusion( vec3 s, vec3 d )
		{
			return s + d - 2.0 * s * d;
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	
	return "%s.rgb = exclusion(%s.rgb, %s.rgb);" % [output_vars[0], input_vars[0], input_vars[1]]
