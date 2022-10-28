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

tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeTriangle

func _init():
	set_input_port_default_value(1, Vector3(0.5, 0.25, 0.0))
	set_input_port_default_value(2, Vector3(0.25, 0.5, 0.0))

func _get_name():
	return "Triangle"

func _get_category():
	return "VisualShaderExtras"

func _get_subcategory():
	return "Shapes"

func _get_description():
	return "Signed Distance Triangle Shape"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0:
			return "uv"
		1:
			return "position"
		2:
			return "proportions"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR
		2:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return ""

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return """
		float sdTriangleIsosceles( in vec2 p, in vec2 q )
		{
			p.x = abs(p.x);
			vec2 a = p - q*clamp( dot(p,q)/dot(q,q), 0.0, 1.0 );
			vec2 b = p - q*vec2( clamp( p.x/q.x, 0.0, 1.0 ), 1.0 );
			float s = -sign( q.y );
			vec2 d = min( vec2( dot(a,a), s*(p.x*q.y-p.y*q.x) ),
						  vec2( dot(b,b), s*(p.y-q.y)  ));
			return -sqrt(d.x)*sign(d.y);
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	
	if input_vars[0]:
		uv = input_vars[0]
	
	return "%s = sdTriangleIsosceles(%s.xy - %s.xy, %s.xy);" % [output_vars[0], uv, input_vars[1], input_vars[2]]
