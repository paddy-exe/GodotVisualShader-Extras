# based on this shadertoy source: https://www.shadertoy.com/view/XdS3RW
tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeLighterColor

func _get_name():
	return "BlendLighterColor"

func _get_category():
	return "VisualShaderExtras"

func _get_subcategory():
	return "BlendModes"

func _get_description():
	return "Lighter Color Blending Mode"

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
		vec3 lighterColor( vec3 s, vec3 d )
		{
			return (s.x + s.y + s.z > d.x + d.y + d.z) ? s : d;
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	
	return "%s.rgb = lighterColor(%s.rgb, %s.rgb);" % [output_vars[0], input_vars[0], input_vars[1]]
