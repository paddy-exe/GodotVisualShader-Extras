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
class_name VisualShaderNodeSamplerNormalMapZ

func _get_name():
	return "RestoreNormalMapZ"

func _get_category():
	return "VisualShaderExtras/Utility"

func _get_description():
	return """Adds the correct Z vector back to normal maps.
Use this if you want a detailed normal map.
NB: Your Sampler Type must be Normal Map.
Don't use this on mobile."""

func _is_available(mode, type):
	return mode == VisualShader.MODE_SPATIAL
	
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
	
func _get_input_port_count():
	return 2

func _get_input_port_name(port):
	match port:
		0: return "UV"
		1: return "Normal Map Sampler"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1: return VisualShaderNode.PORT_TYPE_SAMPLER
		
## return all the functions (in the ShaderLib Dict) that you want
## to use.
func _get_global_func_names()->Array:
	return ["normal_map_add_z"]
	
func _get_global_code(mode):
	return ShaderLib.prep_global_code(self)
	
func _get_code(input_vars, output_vars, mode, type):
	var inuv = "UV"
	if input_vars[0]:
		inuv = input_vars[0]
		
	var code = """
vec3 normal_map_texture = textureLod({normal_texture_sampler}, {inuv}, 0.).rgb;

{out_normal_map} = normal_map_add_z(
	normal_map_texture, 
	{inuv},
	TANGENT,
	BINORMAL,
	NORMAL);
	""".format(
	{
	"inuv" : inuv,
	"normal_texture_sampler": input_vars[1],
	"out_normal_map" : output_vars[0] 
	})
	return ShaderLib.rename_functions(self, code)