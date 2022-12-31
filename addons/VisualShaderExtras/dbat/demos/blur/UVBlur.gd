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

@tool
extends VisualShaderNodeCustom
class_name TempVisualShaderNodeBlur

func _get_name():
	return "UVBlur"

func _get_version():
	return "1"
	
func _get_category():
	return "DBAT/"

func _get_description():
	return LizardShaderLibrary.format_description(self,
	"Hope.")

#func _get_issues():
#	return ""

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_2D

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_2D
	
func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "UV"
	
func _init() -> void:
	pass
#	set_input_port_default_value(0, Vector2(2, 2))
#	set_input_port_default_value(1, 0.0) #rot
#	set_input_port_default_value(2, 0.0) #randomize
#	set_input_port_default_value(3, 0.5) #shift
	
func _get_input_port_count():
	return 1

func _get_input_port_name(port):
	match port:
		0: return "UV in"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D

#func _get_global_code(mode):
#	return """
#	uniform float lod: hint_range(0.0, 5) = 0.0;
#	 """
#
#func _get_code(input_vars, output_vars, mode, type):
#	return """
#	vec4 color = texture({incol}, {inuv}, lod);
#	{outcol} = color;
#	""".format(
#		{
#		"incol": input_vars[0],
#		"inuv" : input_vars[1],
#		"outcol":output_vars[0] 
#		})

func _get_global_code(mode):
	return """
	uniform float lod: hint_range(0.0, 5) = 0.0;
	uniform float sigma = 12.0;
	"""

func _get_code(input_vars, output_vars, mode, type):
	return """
// Generate a blur kernel using a Gaussian function
const int kernelSize = 9;
float kernel[kernelSize];

float sum = 0.0;
for (int i = 0; i < kernelSize; i++) {
  float x = float(i - kernelSize / 2);
  kernel[i] = exp(-x * x / (2.0 * sigma * sigma)) / (sqrt(2.0 * 3.14159265) * sigma);
  sum += kernel[i];
}

// Normalize the kernel so that its sum is 1.0
for (int i = 0; i < kernelSize; i++) {
  kernel[i] /= sum;
}

// Convolve the blur kernel with the UV coordinates
vec2 uv = vec2(0.0);
for (int i = 0; i < kernelSize; i++) {
  uv += {inuv} * kernel[i];
}

// Sample the texture using the blurred UV coordinates
//vec4 color = texture({sampler}, uv); 

// Output the blurred version of the texture
{outcol} = uv;
""".format(
		{
		"inuv" : input_vars[0],
		"outcol":output_vars[0] 
		})

func gpt():
	return """
	// Generate a blur kernel using a Gaussian function
const int kernelSize = 9;
float kernel[kernelSize];

float sum = 0.0;
for (int i = 0; i < kernelSize; i++) {
  float x = float(i - kernelSize / 2);
  kernel[i] = exp(-x * x / (2.0 * sigma * sigma)) / (sqrt(2.0 * 3.14159265) * sigma);
  sum += kernel[i];
}

// Normalize the kernel so that its sum is 1.0
for (int i = 0; i < kernelSize; i++) {
  kernel[i] /= sum;
}

// Convolve the blur kernel with the UV coordinates
vec2 uv = vec2(0.0);
for (int i = 0; i < kernelSize; i++) {
  uv += texCoord * kernel[i];
}

// Sample the texture using the blurred UV coordinates
vec4 color = texture2D(texture, uv);

// Output the blurred version of the texture
gl_FragColor = color;
"""


