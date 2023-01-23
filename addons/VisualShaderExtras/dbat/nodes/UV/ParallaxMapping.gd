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
class_name VisualShaderNodeParallaxMapping

func _get_name():
	return "ParallaxMapping"

func _get_category():
	return "VisualShaderExtras/UV"

func _get_description():
	return """Creates dramatic depth illusion from a height map. Same as the Height options in the Spatial shader, but available as a node."""

func _is_available(mode, type):
	return mode == VisualShader.MODE_SPATIAL
	
func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_2D

func _get_output_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1: return VisualShaderNode.PORT_TYPE_SCALAR
	
func _get_output_port_count():
	return 2

func _get_output_port_name(port: int):
	match port:
		0: return "UV"
		1: return "Depth"
	
func _init() -> void:
	set_input_port_default_value(2, 5.0)
	set_input_port_default_value(3, 8)
	set_input_port_default_value(4, 32)
	set_input_port_default_value(5, Vector2(1,1))
	
func _get_input_port_count():
	return 6

func _get_input_port_name(port):
	match port:
		0: return "UV"
		1: return "Height Sampler"
		2: return "Height Scale"
		3: return "Min Layers"
		4: return "Max Layers"
		5: return "Flip"
		
func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1: return VisualShaderNode.PORT_TYPE_SAMPLER
		2: return VisualShaderNode.PORT_TYPE_SCALAR
		3: return VisualShaderNode.PORT_TYPE_SCALAR_INT
		4: return VisualShaderNode.PORT_TYPE_SCALAR_INT
		5: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		
## return all the functions (in the ShaderLib Dict) that you want
## to use.
#func _get_global_func_names()->Array:
#	return ["world_normal_mask"]

#func _get_global_code(mode):
#	return ShaderLib.prep_global_code(self)

func _get_code(input_vars, output_vars, mode, type):
	var uv = input_vars[0] if input_vars[0] else "UV"
	var code = """
// Code taken from Godot's Spatial Shader
float heightmap_scale = {heightmap_scale};
int heightmap_min_layers = {heightmap_min_layers};
int heightmap_max_layers = {heightmap_max_layers};
vec2 heightmap_flip = {heightmap_flip};
vec2 base_uv = {uv};
{
	
	vec3 view_dir = normalize(normalize(-VERTEX)*mat3(TANGENT*heightmap_flip.x,-BINORMAL*heightmap_flip.y,NORMAL));
	float num_layers = mix(float(heightmap_max_layers),float(heightmap_min_layers), abs(dot(vec3(0.0, 0.0, 1.0), view_dir)));
	float layer_depth = 1.0 / num_layers;
	float current_layer_depth = 0.0;
	vec2 P = view_dir.xy * heightmap_scale * 0.01;
	vec2 delta = P / num_layers;
	vec2 ofs = base_uv;
	float depth = 1.0 - texture({texture_heightmap}, ofs).r;
	float current_depth = 0.0;
	while(current_depth < depth) {
		ofs -= delta;
		depth = 1.0 - texture({texture_heightmap}, ofs).r;
		current_depth += layer_depth;
	}
	vec2 prev_ofs = ofs + delta;
	float after_depth  = depth - current_depth;
	float before_depth = ( 1.0 - texture({texture_heightmap}, prev_ofs).r  ) - current_depth + layer_depth;
	float weight = after_depth / (after_depth - before_depth);
	ofs = mix(ofs,prev_ofs,weight);
	
	{uvout} = ofs;
	{depth} = layer_depth;
}
""".format(
	{
	"uv": uv,
	"texture_heightmap" : input_vars[1],
	"heightmap_scale" : input_vars[2],
	"heightmap_min_layers" : input_vars[3],
	"heightmap_max_layers" : input_vars[4],
	"heightmap_flip" : input_vars[5],
	"uvout" : output_vars[0],
	"depth": output_vars[1]
	})
	return code
