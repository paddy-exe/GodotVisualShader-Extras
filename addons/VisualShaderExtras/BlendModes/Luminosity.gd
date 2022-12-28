@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeLuminosity

func _get_name():
	return "BlendLuminosity"

func _get_category():
	return "VisualShaderExtras/BlendModes"

func _get_description():
	return "Luminosity Blending Mode"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_input_port_count():
	return 2

func _get_input_port_name(port):
	match port:
		0:
			return "Top layer"
		1:
			return "Bottom layer"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "Output"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_global_code(mode):
	return """
		vec3 blend_luminosity( vec3 c1, vec3 c2 )
		{
			float dLum = dot(vec3(c2), vec3(0.3, 0.59, 0.11));
			float sLum = dot(vec3(c1), vec3(0.3, 0.59, 0.11));
			float lum = sLum - dLum;
			vec3 c = vec3(c2) + lum;
			float minC = min(min(c.x, c.y), c.z);
			float maxC = max(max(c.x, c.y), c.z);
			if(minC < 0.0) return sLum + ((c - sLum) * sLum) / (sLum - minC);
			else if(maxC > 1.0) return sLum + ((c - sLum) * (1.0 - sLum)) / (maxC - sLum);
			else return c;
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	
	return "%s.rgb = blend_luminosity(%s.rgb, %s.rgb);" % [output_vars[0], input_vars[0], input_vars[1]]
