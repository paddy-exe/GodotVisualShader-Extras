tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeSceneDepth

func _get_name():
	return "SceneDepth"

func _get_category():
	return "VisualShaderExtras"

func _get_subcategory():
	return "Utility"

func _get_description():
	return "Returns the linear scene depth by reading the Depth texture"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0:
			return "Depth texture"
		1:
			return "Screen UV"
		2:
			return "Inv-Proj-Matrix"


func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SAMPLER
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR
		2:
			return VisualShaderNode.PORT_TYPE_TRANSFORM

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "Scene Depth"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	# depth is the raw output of the depth texture that is logarithmic
	# ndc is just normalized device coords between -1.0 and 1.0
	# the buffer removes the logarithm by converting it back to view space (its weird but welcome to Godot)
	# then just return the length of buffer, but buffer.w = 1.0 / clipping plane
	# so buffer.xyz / buffer.w = buffer.xyz * clipping_plane_length
	# our new value is negative because it goes from object -> camera
	# but depth is from camera -> object
	# So negate and return
	return """
		float scene_depth(sampler2D __depth_tex, vec2 __screen_uv, mat4 __inv_proj_mat)
		{
			float __depth = texture(__depth_tex, __screen_uv.xy).r;
			vec3 __ndc = vec3(__screen_uv, __depth) * 2.0 - 1.0;
			vec4 __buffer = __inv_proj_mat * vec4(__ndc, 1.0);
			return -(__buffer.xyz / __buffer.w).z;
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	var depth_tex = "DEPTH_TEXTURE"
	var screen_uv = "SCREEN_UV"
	var inv_proj_mat = "INV_PROJECTION_MATRIX"
	
	if input_vars[0]:
		depth_tex = input_vars[0]
	elif input_vars[1]:
		screen_uv = input_vars[1]
	elif input_vars[2]:
		inv_proj_mat = input_vars[2]
	
	return "%s = scene_depth(%s, %s.xy, %s);" % [output_vars[0], depth_tex, screen_uv, inv_proj_mat]
