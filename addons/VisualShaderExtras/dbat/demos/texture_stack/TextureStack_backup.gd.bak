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
class_name TempVisualShaderNodeTextureStack

func _get_name():
	return "TextureStack"

func _get_version():
	return "1"
	
func _get_category():
	return "VisualShaderExtras/Utility"

func _get_description():
	return LizardShaderLibrary.format_description(self,
	"""....""")

#func _is_available(mode, type):
#	return mode == VisualShader.MODE_SPATIAL
	
func _is_highend():
	return true #mark as PC only.

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_output_port_count():
	return 7

func _get_output_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		3: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		4: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		5: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		6: return VisualShaderNode.PORT_TYPE_SCALAR
	
func _get_output_port_name(port: int):
	match port:
		0: return "UV"
		1: return "A rgb"
		2: return "O rgb"
		3: return "R rgb"
		4: return "M rgb"
		5: return "Norm rgb"
		6: return "Height"
	
#func _init() -> void:
#	set_input_port_default_value(2, Vector3.UP)
#	set_input_port_default_value(3, 0.)
#	set_input_port_default_value(4, 0.)
	
func _get_input_port_count():
	return 7

func _get_input_port_name(port):
	match port:
		0: return "UV in"
		1: return "Albedo"
		2: return "Occlusion"
		3: return "Roughness"
		4: return "Metallic"
		5: return "Normalmap"
		6: return "Height"
		
func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1: return VisualShaderNode.PORT_TYPE_SAMPLER #sampler
		2: return VisualShaderNode.PORT_TYPE_SAMPLER #sampler
		3: return VisualShaderNode.PORT_TYPE_SAMPLER #sampler
		4: return VisualShaderNode.PORT_TYPE_SAMPLER #sampler
		5: return VisualShaderNode.PORT_TYPE_SAMPLER #sampler
		6: return VisualShaderNode.PORT_TYPE_SAMPLER

#func _get_global_code(mode):
#	return LizardShaderLibrary.normal_map_add_z \
#	+ LizardShaderLibrary.world_normal_mask \
#	+ LizardShaderLibrary.mask_blend
#

func tlod(invar,key):
	var s
	if invar:
		s = "vec3 tex_%s = textureLod({sampler_%s}, {inuv}, 0.).rgb;" % [key,key]
		if key == "H":
			s+="{out_%s} = tex_%s.r;" % [key,key]
		else:
			s+= "{out_%s} = tex_%s;" % [key,key]
		s+="\n"
		return s
	return ""
	
func _get_code(input_vars, output_vars, mode, type):
	var inuv = "UV"
	if input_vars[0]:
		inuv = input_vars[0]
	
	var s = tlod(input_vars[1],"A")
	s += tlod(input_vars[2],"O")
	s += tlod(input_vars[3],"R")
	s += tlod(input_vars[4],"M")
	s += tlod(input_vars[5],"NM")
	s += tlod(input_vars[6],"H")
	
	s = s.format({
		"inuv" : inuv,
		"sampler_A": input_vars[1],
		"sampler_O": input_vars[2],
		"sampler_R": input_vars[3],
		"sampler_M": input_vars[4],
		"sampler_NM": input_vars[5],
		"sampler_H": input_vars[6],

		"out_A": output_vars[1],
		"out_O": output_vars[2],
		"out_R": output_vars[3],
		"out_M": output_vars[4],
		"out_NM": output_vars[5],
		"out_H": output_vars[6]
		})
	return s + """
{uv_out} = {inuv};
""".format(
{
"inuv" : inuv,
"uv_out": output_vars[0],
})
