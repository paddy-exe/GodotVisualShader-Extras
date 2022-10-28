# from https://github.com/thnewlands/unity-surfaceshader-flipbook
# 
# MIT License
#
# Copyright (c) 2017 Thomas Newlands
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeUVFlipbook

func _init():
	set_input_port_default_value(1, 1)
	set_input_port_default_value(2, 1)
	set_input_port_default_value(3, 0)
	set_input_port_default_value(4, 1)
	set_input_port_default_value(5, 0.3)

func _get_name():
	return "UVFlipbook"

func _get_category():
	return "VisualShaderExtras"

func _get_subcategory():
	return "UV"

func _get_description():
	return "UV Flipbook Animation"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count():
	return 6

func _get_input_port_name(port):
	match port:
		0:
			return "uv"
		1:
			return "columns"
		2:
			return "rows"
		3:
			return "starting frame"
		4:
			return "ending frame"
		5:
			return "animation speed"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR
		4:
			return VisualShaderNode.PORT_TYPE_SCALAR
		5:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return ""

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode):
	return """
		vec2 flipbook_anim(vec2 __uv, int __columns, int __rows, int __starting_frame, int __ending_frame, float __anim_speed) {
			__starting_frame += int(fract(TIME * __anim_speed) * float(__ending_frame));
			float frame = float(clamp(__starting_frame, 0, __ending_frame));
			vec2 offPerFrame = vec2((1.0 / float(__columns)), (1.0 / float(__rows)));
			
			vec2 sprite_size = vec2(__uv.x / float(__columns), __uv.y / float(__rows));
			vec2 current_sprite = vec2(0.0, 1.0 - offPerFrame.y);
			current_sprite.x += frame * offPerFrame.x;
			float rowIndex;
			current_sprite.y -= rowIndex * offPerFrame.y;
			current_sprite.x -= rowIndex * float(__columns) * offPerFrame.x;
			
			vec2 sprite_uv = (sprite_size + current_sprite);
			
			return sprite_uv;
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	
	if input_vars[0]:
		uv = input_vars[0]	
	
	return "%s.xy = flipbook_anim(%s.xy, int(%s), int(%s), int(%s), int(%s), %s );" % [output_vars[0], uv, input_vars[1], input_vars[2], input_vars[3], input_vars[4], input_vars[5]]

