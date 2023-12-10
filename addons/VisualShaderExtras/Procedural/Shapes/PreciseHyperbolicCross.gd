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
class_name VisualShaderNodePreciseHyperbolicCross

func _init():
	set_input_port_default_value(1, Vector2(0.5, 0.25))
	set_input_port_default_value(2, Vector2(0.5, 0.5))
	set_input_port_default_value(3, 0.13)

func _get_name():
	return "SDF PreciseHyperBolicCross Shape"

func _get_category():
	return "VisualShaderExtras/Procedural"

func _get_description():
	return "Signed Distance Field (SDF) Precise Hyperbolic Cross Shape"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 4

func _get_input_port_name(port):
	match port:
		0:
			return "UV"
		1:
			return "Position"
		2:
			return "Proportions"
		3:
			return "Size"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D
		2:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return ""

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return """
		float sdPreciseHyperbolicCross( in vec2 p, float k )
		{
			// scale
			float s = 1.0/k - k;
			p = p*s;
			// symmetry
			p = abs(p);
			p = (p.x>p.y) ? p.yx : p.xy;
			// offset
			p += k;
			
			// solve quartic (for details see https://www.shadertoy.com/view/ftcyW8)
			float x2 = p.x*p.x/16.0;
			float y2 = p.y*p.y/16.0;
			float r = (p.x*p.y-4.0)/12.0;
			float q = y2-x2;
			float h = q*q-r*r*r;
			float u;
			if( h<0.0 )
			{
				float m = sqrt(r);
				u = m*cos( acos(q/(r*m) )/3.0 );
			}
			else
			{
				float m = pow(sqrt(h)+q,1.0/3.0);
				u = (m+r/m)/2.0;
			}
			float w = sqrt(u+x2);
			float x = p.x/4.0-w+sqrt(2.0*x2-u+(p.y-x2*p.x*2.0)/w/4.0);
			
			// clamp arm
			x = max(x,k);
			
			// compute distance to closest point
			float d = length( p-vec2(x,1.0/x) ) / s;

			// sign
			return p.x*p.y < 1.0 ? -d : d;
		}
	"""

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	
	if input_vars[0]:
		uv = input_vars[0]
	
	return "%s = sdPreciseHyperbolicCross((%s.xy - %s.xy)*(2.0-%s.xy), %s);" % [output_vars[0], uv, input_vars[1], input_vars[2], input_vars[3]]
