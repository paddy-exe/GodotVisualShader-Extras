# The MIT License
# Copyright © 2022 Inigo Quilez
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

@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeBox2

func _init():
	set_input_port_default_value(1, Vector2(0.5, 0.5))
	set_input_port_default_value(2, Vector2(0.25, 0.25))
	set_input_port_default_value(3, 0.25)
	set_input_port_default_value(4, 0.) # outline

func _get_name():
	return "Box2"

func _get_category():
	return "VisualShaderExtras/Shapes/PR"

func _get_description():
	return "Signed Distance Box Shape3D"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 5

func _get_input_port_name(port):
	match port:
		0: return "UV"
		1: return "Position"
		2: return "Proportions"
		3: return "Outline Thickness"
		4: return "Feather"
		
func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		2: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		3: return VisualShaderNode.PORT_TYPE_SCALAR #outline
		3: return VisualShaderNode.PORT_TYPE_SCALAR #feather

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "Mask"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return """
//Original - not sure how to smooth this
float sdBox( in vec2 __position, in vec2 __proportions )
{
 vec2 __d = abs(__position) - __proportions;
 return length(max(__d, 0.0)) + min(max(__d.x, __d.y), 0.0);
}




//float sdBox2( in vec2 __position, in vec2 __proportions, float _feather)
//{
// vec2 __d = abs(__position) - __proportions;
// float f = length(max(__d, 0.0)) + min(max(__d.x, __d.y), 0.0);
// return smoothstep(f,f + _feather ,__d);
//}

float roundedFrame (vec2 _uv, vec2 pos, vec2 size, float thickness, float radius)
{
  float d = length(max(abs(_uv - pos),size) - size) - radius;
  return smoothstep(0.55, 0.45, abs(d / thickness) * 5.0);
}

float sdRect(vec2 p, vec2 sz) {
	//
	vec2 d = abs(p) - sz; 
	//
	float outside = length(max(d, 0.));
	float inside = min(max(d.x, d.y), 0.);
	return outside + inside;
}

"""

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	if input_vars[0]:
		uv = input_vars[0]
	#return "{out} = roundedFrame({uv}, {pos}, {proportions}, {feather}, {outline});" \
	#return "{out} = sdBox2({pos}, {proportions}, {feather});" \
	return "{out} = sdRect({pos}, {proportions});//, {feather});" \
	.format({
		"uv": uv,
		"pos": input_vars[1],
		"proportions": input_vars[2],
		"feather": input_vars[3],
		"outline": input_vars[4],
		"out" : output_vars[0]
	})
	
#	return "%s = sdBox(%s.xy - %s.xy, %s.xy);" % [output_vars[0], uv, input_vars[1], input_vars[2]]
