@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeLuminosityAdvanced

func _get_name():
	return "BlendLuminosity"

func _init() -> void:
	set_input_port_default_value(2, 0.5)

func _get_category():
	return "VisualShaderExtras/BlendModes"

func _get_description():
	return "Luminosity Blending Mode"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0:
			return "Top layer"
		1:
			return "Bottom layer"
		2:
			return "Opacity"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "Output"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_global_code(mode):
	return """
		float blend_luminosity_f( float c1, float c2 )
		{
			float dLum = dot(vec3(c2), vec3(0.3, 0.59, 0.11));
			float sLum = dot(vec3(c1), vec3(0.3, 0.59, 0.11));
			float lum = sLum - dLum;
			float c = c2 + lum;
			if(c < 0.0) return sLum + ((c - sLum) * sLum) / (sLum - c);
			else if(c > 1.0) return sLum + ((c - sLum) * (1.0 - sLum)) / (c - sLum);
			else return c;
		}
		
		vec3 blend_luminosity(vec3 c1, vec3 c2, float opacity)
		{
			return opacity*vec3(blend_luminosity_f(c1.x, c2.x), blend_luminosity_f(c1.y, c2.y), blend_luminosity_f(c1.z, c2.z)) + (1.0-opacity)*c2;
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	
	return "%s.rgb = blend_luminosity(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
