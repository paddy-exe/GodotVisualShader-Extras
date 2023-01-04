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

@tool
extends VisualShaderNodeCustom
class_name TempVisualShaderNodeLodBlur

func _get_name():
	return "LodBlur"

func _get_version():
	return "1"
	
func _get_category():
	return "VisualShaderExtras/Filters"

func _get_description():
	return LizardShaderLibrary.format_description(self,
	"Blurs using the mipmaps of this texture.\nNB: Be sure to try different Sampler Filters.\nBlurs textures added via a Texture2DParameter Node.")

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_3D
	
func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "Output"
	
func _init() -> void:
	pass
	set_input_port_default_value(2, 0.0)
	
func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0: return "UV"
		1: return "Texture Sampler"
		2: return "Blur Amount"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1: return VisualShaderNode.PORT_TYPE_SAMPLER
		2: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_code(input_vars, output_vars, mode, type):
	var inuv = "UV"
	if input_vars[0]:
		inuv = input_vars[0]
		
	return """
	//When the sampler is set to Linear Mipmap it works best.
	//The Bias will cause blurring.
	vec4 color = textureLod({sampler}, {inuv}, {bias});
	{outcol} = color.rgb;
	""".format(
		{
		"inuv": inuv,
		"sampler": input_vars[1],
		"bias"   : input_vars[2],
		"outcol" : output_vars[0] 
		})
