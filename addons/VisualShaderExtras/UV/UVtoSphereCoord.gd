@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeUVtoSphereCoord

func _get_name():
	return "UVtoSphereCoord"

func _init() -> void:
	set_input_port_default_value(1, Vector3(0.0, 0.0, 0.0))

func _get_category():
	return "VisualShaderExtras/UV"

func _get_description():
	return "UV to Sphere Coord"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_2D

func _get_input_port_count():
	return 2

func _get_input_port_name(port):
	match port:
		0:
			return "Sphere Surface Point"
		1:
			return "Sphere Center"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "UV"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_2D

func _get_global_code(mode):
	return """
		vec2 uv_to_sphere_coord(vec3 sphere_surface_point, vec3 sphere_center)
		{
			vec3 n = normalize(sphere_surface_point - sphere_center);
			float sphere_u = atan(n.x, n.z) / (2.0*PI) + 0.5;
			float sphere_v = n.y * 0.5 + 0.5;
			return vec2(sphere_u, sphere_v);
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	return "%s.xy = uv_to_sphere_coord(%s.xyz, %s.xyz);" % [output_vars[0], input_vars[0], input_vars[1]]
