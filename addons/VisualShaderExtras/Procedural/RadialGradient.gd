@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeRadialGradient

func _init():
	set_input_port_default_value(1, Vector2(0.5,0.5))
	set_input_port_default_value(2, 2.0)

func _get_name():
	return "RadialGradient"

func _get_category():
	return "VisualShaderExtras/Procedural"

func _get_description():
	return "UV Radial gradient with an adjustable fraction size"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0:
			return "UV"
		1:
			return "Offset"
		2:
			return "Fraction size"

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
	return "Gradient"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return """
		float uv_radial_gradient(vec2 uv, vec2 offset, float fraction_size) {
			vec2 __uv = uv - offset;
			float grad = atan(__uv.x, __uv.y);
			grad = fract(grad / (fraction_size * PI));
			return grad;
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	
	if input_vars[0]:
		uv = input_vars[0]
	
	return "%s = uv_radial_gradient(%s.xy, %s.xy, %s);" % [output_vars[0], uv, input_vars[1], input_vars[2]]
