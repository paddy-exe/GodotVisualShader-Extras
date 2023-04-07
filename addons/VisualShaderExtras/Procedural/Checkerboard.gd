@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeCheckerboard

func _get_name():
	return "Checkerboard"

func _init() -> void:
	set_input_port_default_value(1, Vector2(8.0, 8.0))

func _get_category():
	return "VisualShaderExtras/Procedural"

func _get_description():
	return "Checkerboard Pattern with two given input colors"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_input_port_count():
	return 4

func _get_input_port_name(port):
	match port:
		0:
			return "UV"
		1:
			return "Tiling"
		2:
			return "Color"
		3:
			return "Color"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D
		2:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D
		3:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D
			
func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return ""

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_global_code(mode):
	return """
		vec3 checkerboard(vec2 _uv, vec2 _tiling, vec3 _color1, vec3 _color2) {
			float _tiling_x = floor(mod((_uv.x / (1.0 / _tiling.x)), 2.0));
			float _tiling_y = floor(mod((_uv.y / (1.0 / _tiling.y)), 2.0));
			bool _compare_bool = (abs(_tiling_x - _tiling_y) < 0.00001);
			return mix(_color1.xyz, _color2.xyz, (_compare_bool ? 1.0 : 0.0));
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	
	if input_vars[0]:
		uv = input_vars[0]
	
	return "%s.xyz = checkerboard(%s.xy, %s.xy, %s, %s);" % [output_vars[0], uv, input_vars[1], input_vars[2], input_vars[3]]
