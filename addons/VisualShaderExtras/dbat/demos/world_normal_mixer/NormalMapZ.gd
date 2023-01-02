# The MIT License
# Copyright © 2022 Donn Ingle (on shoulders of giants)
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), 
# to deal in the Software without restriction, including without limitation 
# the rights to use, copy, modify, merge, publish, distribute, sublicense, 
# and/or sell copies of the Software, and to permit persons to whom the 
# Software is furnished to do so, subject to the following conditions: 
# The above copyright notice and this permission notice shall be included 
# in all copies or substantial portions of the Software. 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# and

## 2022 Kasper Arnklit Frandsen - Public Domain - No Rights Reserved

@tool
extends VisualShaderNodeCustom
class_name TempVisualShaderNodeSamplerNormalMapZ

func _get_name():
	return "Sampler Restore NormalMap Z"

func _get_version():
	return "1"
	
func _get_category():
	return "VisualShaderExtras/Samplers/PR"

func _get_description():
	return LizardShaderLibrary.format_description(self,
	"""Adds the correct Z vector back to normal maps.
Use this if you want a detailed normal map.
NB: Your Sampler Type must be Normal Map.
Don't use this on mobile.""")

func _is_highend():
	return true #mark as PC only.

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_3D
	
func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "Normal Map with Z"
	
func _init() -> void:
	pass
	set_input_port_default_value(2, 0.0)
	
func _get_input_port_count():
	return 2

func _get_input_port_name(port):
	match port:
		0: return "UV in"
		1: return "Normal Map Sampler"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1: return VisualShaderNode.PORT_TYPE_SAMPLER

func _get_code(input_vars, output_vars, mode, type):
	var inuv = "UV"
	if input_vars[0]:
		inuv = input_vars[0]
		
	return """
// Godot strips the z value from imported Normal Maps.
// It does this for two reasons:
// 1. Obtaining better compression because the z can be calculated by shader.
//    Compression boosts speed of CPU to GPU transfer.
// 2. On mobile devices they do not do that calculation. They either ignore the z
//    or do some other calculation, but the normal one (below) is apparently too slow
//    or power-hungry for mobile devices.

vec3 ntex = textureLod({normal_texture_sampler}, {inuv}, 0.).rgb;

// 2022 Kasper Arnklit Frandsen - Public Domain - No Rights Reserved

// Unpack the background normal map.
vec3 bg_normal = ntex * 2.0 - 1.0;

// Recalculate z-component of the normal map with the Pythagorean theorem.
bg_normal.z = sqrt(1.0 - bg_normal.x * bg_normal.x - bg_normal.y * bg_normal.y);

// Apply the tangent-space normal map to the view-space normals.
vec3 normal_applied = bg_normal.x * TANGENT + bg_normal.y * BINORMAL + bg_normal.z * NORMAL;

{out_normal_map} = normal_applied;
""".format(
{
"inuv" : inuv,
"normal_texture_sampler": input_vars[1],
"out_normal_map" : output_vars[0] 
})
