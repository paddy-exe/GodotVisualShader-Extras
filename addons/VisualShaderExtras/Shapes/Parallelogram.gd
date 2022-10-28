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
class_name VisualShaderNodeParallelogram

func _init():
	set_input_port_default_value(1, Vector3(0.5, 0.5, 0.0))
	set_input_port_default_value(2, 0.15)
	set_input_port_default_value(3, 0.3)
	set_input_port_default_value(4, 0.2)

func _get_name():
	return "Parallelogram"

func _get_category():
	return "VisualShaderExtras"

func _get_subcategory():
	return "Shapes"

func _get_description():
	return "Signed Distance Parallelogram Shape"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 5

func _get_input_port_name(port):
	match port:
		0:
			return "uv"
		1:
			return "position"
		2:
			return "width"
		3:
			return "height"
		4:
			return "skew"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR
		4:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return ""

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return """
		float sdParallelogram( in vec2 p, float wi, float he, float sk )
		{
			vec2 e = vec2(sk,he);
			p = (p.y<0.0)?-p:p;
			vec2  w = p - e; w.x -= clamp(w.x,-wi,wi);
			vec2  d = vec2(dot(w,w), -w.y);
			float s = p.x*e.y - p.y*e.x;
			p = (s<0.0)?-p:p;
			vec2  v = p - vec2(wi,0); v -= e*clamp(dot(v,e)/dot(e,e),-1.0,1.0);
			d = min( d, vec2(dot(v,v), wi*he-abs(s)));
			return sqrt(d.x)*sign(-d.y);
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	
	if input_vars[0]:
		uv = input_vars[0]
	
	return "%s = sdParallelogram(%s.xy - %s.xy, %s, %s, %s);" % [output_vars[0], uv, input_vars[1], input_vars[2], input_vars[3], input_vars[4]]
