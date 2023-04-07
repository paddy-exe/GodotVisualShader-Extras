# Copyright 2021, Stefan Gustavson and Ian MacEwan (stefan.gustavson@gmail.com, ijm567@gmail.com)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
# associated documentation files (the "Software"), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, publish, distribute, 
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or 
# substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
# SOFTWARE.

# // psrdnoise (c) Stefan Gustavson and Ian McEwan,
# // ver. 2021-12-02, published under the MIT license:
# // https://github.com/stegu/psrdnoise/

@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodePSRDNoise2D

func _get_name():
	return "PSRDNoise2D"

func _init() -> void:
	set_input_port_default_value(0, Vector2(0.0, 0.0))
	set_input_port_default_value(1, Vector2(1.0, 1.0))
	set_input_port_default_value(2, 1.0)

func _get_category():
	return "VisualShaderExtras/Procedural"

func _get_description():
	return "Seamless performant 2D noise for shaders"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0:
			return "Coordinates"
		1:
			return "Period"
		2:
			return "Alpha"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
			
func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "Output"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return """
		float psrdnoise2_with_gradient(vec2 x, vec2 period, float alpha, out vec2 gradient) {
			vec2 uv = vec2(x.x+x.y*0.5, x.y);
			vec2 i0 = floor(uv), f0 = fract(uv);
			float cmp = step(f0.y, f0.x);
			vec2 o1 = vec2(cmp, 1.0-cmp);
			vec2 i1 = i0 + o1, i2 = i0 + 1.0;
			vec2 v0 = vec2(i0.x - i0.y*0.5, i0.y);
			vec2 v1 = vec2(v0.x + o1.x - o1.y*0.5, v0.y + o1.y);
			vec2 v2 = vec2(v0.x + 0.5, v0.y + 1.0);
			vec2 x0 = x - v0, x1 = x - v1, x2 = x - v2;
			vec3 iu, iv, xw, yw;
			if(any(greaterThan(period, vec2(0.0)))) {
				xw = vec3(v0.x, v1.x, v2.x);
				yw = vec3(v0.y, v1.y, v2.y);
				if(period.x > 0.0)
				xw = mod(vec3(v0.x, v1.x, v2.x), period.x);
				if(period.y > 0.0)
				yw = mod(vec3(v0.y, v1.y, v2.y), period.y);
				iu = floor(xw + 0.5*yw + 0.5); iv = floor(yw + 0.5);
			} else {
				iu = vec3(i0.x, i1.x, i2.x); iv = vec3(i0.y, i1.y, i2.y);
			}
			vec3 hash = mod(iu, 289.0);
			hash = mod((hash*51.0 + 2.0)*hash + iv, 289.0);
			hash = mod((hash*34.0 + 10.0)*hash, 289.0);
			vec3 psi = hash*0.07482 + alpha;
			vec3 gx = cos(psi); vec3 gy = sin(psi);
			vec2 g0 = vec2(gx.x, gy.x);
			vec2 g1 = vec2(gx.y, gy.y);
			vec2 g2 = vec2(gx.z, gy.z);
			vec3 w = 0.8 - vec3(dot(x0, x0), dot(x1, x1), dot(x2, x2));
			w = max(w, 0.0); vec3 w2 = w*w; vec3 w4 = w2*w2;
			vec3 gdotx = vec3(dot(g0, x0), dot(g1, x1), dot(g2, x2));
			float n = dot(w4, gdotx);
			vec3 w3 = w2*w; vec3 dw = -8.0*w3*gdotx;
			vec2 dn0 = w4.x*g0 + dw.x*x0;
			vec2 dn1 = w4.y*g1 + dw.y*x1;
			vec2 dn2 = w4.z*g2 + dw.z*x2;
			gradient = 10.9*(dn0 + dn1 + dn2);
			return 10.9*n;
		}
		
		float psrdnoise2(vec2 x, vec2 period, float alpha) {
			vec2 gradient;
			return psrdnoise2_with_gradient(x, period, alpha, gradient);
		}
		
	"""

func _get_code(input_vars, output_vars, mode, type):
	
	return "%s = psrdnoise2(%s.xy, %s.xy, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
