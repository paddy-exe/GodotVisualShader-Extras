tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeColorDodge

func _get_name():
	return "BlendVividLight"

func _get_category():
	return "VisualShaderExtras"

func _get_subcategory():
	return "BlendModes"

func _get_description():
	return "Color Dodge Blending Mode"

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
		vec3 blend_color_dodge(vec3 __top_col, vec3 __bot_col)
		{
			return __bot_col / (1.0 - __top_col);
		}
		
		vec3 blend_color_burn(vec3 __top_col, vec3 __bot_col)
		{
			return 1.0 - ((1.0 - __bot_col) / __top_col);
		}
		
		float blend_rgb_to_v(vec3 __col) {
			return max(max(__col.r / 255.0, __col.g / 255.0), __col.b / 255.0);
		}
		
		vec3 blend_vivid_light(vec3 __top_col, vec3 __bot_col) {
			if (blend_rgb_to_v(__top_col) > 0.5) {
				return blend_color_dodge(__top_col, __bot_col);
			} else {
				return blend_color_burn(__top_col, __bot_col);
			}
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	
	return "%s.rgb = blend_vivid_light(%s.rgb, %s.rgb);" % [output_vars[0], input_vars[0], input_vars[1]]
