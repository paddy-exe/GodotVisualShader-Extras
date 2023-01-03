# The MIT License
# Copyright © 2022 Inigo Quilez
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

# With assist from https://thebookofshaders.com/09/

# Portions taken from the work of Arnklit under CC0 Licence:
# https://github.com/Arnklit/TutorialResources/blob/main/LICENSE
# Creative Commons Legal Code
#
# CC0 1.0 Universal
#
#    CREATIVE COMMONS CORPORATION IS NOT A LAW FIRM AND DOES NOT PROVIDE
#    LEGAL SERVICES. DISTRIBUTION OF THIS DOCUMENT DOES NOT CREATE AN
#    ATTORNEY-CLIENT RELATIONSHIP. CREATIVE COMMONS PROVIDES THIS
#    INFORMATION ON AN "AS-IS" BASIS. CREATIVE COMMONS MAKES NO WARRANTIES
#    REGARDING THE USE OF THIS DOCUMENT OR THE INFORMATION OR WORKS
#    PROVIDED HEREUNDER, AND DISCLAIMS LIABILITY FOR DAMAGES RESULTING FROM
#    THE USE OF THIS DOCUMENT OR THE INFORMATION OR WORKS PROVIDED
#    HEREUNDER.

## ISSUES:
## There's always one tile that will not rotate randomly. Search me!

@tool
extends VisualShaderNodeCustom
class_name TempVisualShaderNodeTiler2


func _get_name():
	return "Tiler2"

var LSL:LizardShaderLib

func _init() -> void:
	LSL = LizardShaderLib.new()
	
	set_input_port_default_value(0, Vector2(2, 2))
	set_input_port_default_value(1, 0.0) #rot
	set_input_port_default_value(2, 0.0) #randomize
	
func _get_category():
	return "dbatWork/Tiler"

func _get_description():
	return "Tile Stuff"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_input_port_count():
	return 4

func _get_input_port_name(port):
	match port:
		0: return "Tiling down, across"
		1: return "Rotation radians"
		2: return "Randomize rotation"
		3: return "Brick Shift"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D #tile y, x
		1: return VisualShaderNode.PORT_TYPE_SCALAR #radians
		2: return VisualShaderNode.PORT_TYPE_SCALAR #float
		3: return VisualShaderNode.PORT_TYPE_SCALAR #float for bricks
		
func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "UV"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_2D

func _get_global_code(mode):
	#{LIB_rot}
	return """
	//uniform float shift : hint_range(0.0, 2.0) = 0.5; 
vec2 vec2_rotate(vec2 _v2, float _angle, float _row, float _shift) {
	vec2 _pivot = vec2((_v2.x + _shift)/2.0, _v2.y/2.0);
	_v2 -= _pivot;
	_v2 = mat2( vec2(cos(_angle), -sin(_angle)), vec2(sin(_angle), cos(_angle)) ) * _v2;
	_v2 += _pivot;
	return _v2;
}		
	{LIB_rand}
	vec2 brick_tile(vec2 _uv, float _zoom, float _row, float shift)
	{
		_uv *= _zoom;
		_uv.x += step(1.0, _row)  *  shift;
		return fract(_uv);
	}
	""".format({
		"LIB_rot":LSL.vec2_rotate,
		"LIB_rand":LSL.random_float,
		})

func _get_code(input_vars, output_vars, mode, type):
	return """
	//Much simpler to calculate zoom from the tiling vec2
	float zoom = {in_tilexy}.x * {in_tilexy}.y;
	
	vec2 st = UV/{in_tilexy};
	
	//This variation took me ages to work out:
	vec2 unique_val = floor( st * zoom ) / zoom; 
	
	// Now the random rotation: Courtesy Arnklit
	// https://github.com/Arnklit/TutorialResources/tree/main/tiling_rotation
	
	float rand_rotation = (random_float(unique_val) * 2.0 - 1.0) * {rr} * 3.14;
	//float rand_rotation = ( (random_float(unique_val) * {shift} )-({shift}/2.0)  ) * {rr} * 3.14;
	//Just add whatever static rotation may be input:
	rand_rotation += {rot};
	
	float row = mod(st.y, 2.0);
	st = brick_tile(st, zoom, row, {shift});
	//st = vec2_rotate(st, rand_rotation, row, {shift});
	

	{out_uv} = st;
	""".format(
		{
		"in_tilexy":input_vars[0],
		"rot":		input_vars[1],
		"rr":		input_vars[2],
		"shift":	input_vars[3],
		"out_uv":	output_vars[0] 
		})
