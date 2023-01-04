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
class_name TempVisualShaderNodeMaskBlend

func _get_name():
	return "MaskBlend"

func _get_version():
	return "1"
	
func _get_category():
	return "VisualShaderExtras/Utility"

func _get_description():
	return LizardShaderLibrary.format_description(self,
	"""Let's you control the blend and fade of a given mask.""")

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR
	
func _get_output_port_count():
	return 1

func _get_output_port_name(port: int) -> String:
	return "Output"
	
func _init() -> void:
	set_input_port_default_value(0, 0.)
	set_input_port_default_value(1, 0.)
	set_input_port_default_value(2, 0.)
	
func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0: return "Mask Input"
		1: return "Blend Amount"
		2: return "Blend Fade"

func _get_input_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return LizardShaderLibrary.mask_blend

func _get_code(input_vars, output_vars, mode, type):
	return """
{out_float} = mask_blend({offset}, {fade}, {mask_in});
""".format(
{
"mask_in" : input_vars[0],
"offset": input_vars[1],
"fade" : input_vars[2],
"out_float" : output_vars[0] 
})
