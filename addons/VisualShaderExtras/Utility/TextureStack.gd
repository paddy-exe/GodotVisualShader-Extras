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
class_name VisualShaderNodeTextureStack

func _get_name():
	return "TextureStack"

func _get_category():
	return "VisualShaderExtras/Utility"

func _get_description():
	return """A single node to plug multiple Samplers into. If you use the ORM port, it will ignore the individual O, R and M ports, but the outputs will supply the data."""

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

enum {KEY, NAME, PORT_TYPE_IN, PORT_TYPE_OUT}
const names := [
	#[key, name, type_in, type_out]
	["UV", "UV", 		VisualShaderNode.PORT_TYPE_VECTOR_2D, VisualShaderNode.PORT_TYPE_VECTOR_2D],
	["A",  "Albedo",	VisualShaderNode.PORT_TYPE_SAMPLER, VisualShaderNode.PORT_TYPE_VECTOR_4D],
	["ORM","ORM",		VisualShaderNode.PORT_TYPE_SAMPLER, VisualShaderNode.PORT_TYPE_VECTOR_3D],
	["O",  "Occlusion", VisualShaderNode.PORT_TYPE_SAMPLER, VisualShaderNode.PORT_TYPE_SCALAR],
	["R",  "Roughness", VisualShaderNode.PORT_TYPE_SAMPLER, VisualShaderNode.PORT_TYPE_SCALAR],
	["M",  "Metallic",  VisualShaderNode.PORT_TYPE_SAMPLER, VisualShaderNode.PORT_TYPE_SCALAR],
	["N",  "NormalMap", VisualShaderNode.PORT_TYPE_SAMPLER, VisualShaderNode.PORT_TYPE_VECTOR_3D],
	["D",  "Depth",	VisualShaderNode.PORT_TYPE_SAMPLER, VisualShaderNode.PORT_TYPE_SCALAR]
]

func _get_output_port_count():
	return names.size()
	
func _get_output_port_type(port):
	return names[port][PORT_TYPE_OUT]

func _get_output_port_name(port: int):
	return "" #names[port][0]

func _get_input_port_count():
	return names.size()

func _get_input_port_name(port):
	return names[port][NAME]

func _get_input_port_type(port):
	return names[port][PORT_TYPE_IN]

var isorm=false
func create_textureLod_command(invars, outvars, port):
	var s := ""
	var invar = invars[port]
	if invar:
		var key = names[port][KEY]
		var sampler = invar
		var out = outvars[port]

		match key:
			"A": # 4d
				s = "%s = textureLod(%s, {inuv}, 0.);" % [out, sampler]
			"D": # float 1d
				s = "%s = textureLod(%s, {inuv}, 0.).r;" % [out, sampler]
			"ORM": # all three from the ORM input Sampler
				isorm = true
				s = "%s = textureLod(%s, {inuv}, 0.).r;\n" % [outvars[3],sampler]
				s+= "%s = textureLod(%s, {inuv}, 0.).g;\n" % [outvars[4],sampler]
				s+= "%s = textureLod(%s, {inuv}, 0.).b;" % [outvars[5],sampler]
			"N":
				s = "%s = textureLod(%s, {inuv}, 0.).rgb;" % [out, sampler]

			# if ORM port is used, then we want to ignore any others plugged in
			"O" : # 1d from its own sampler
				if not isorm:
					s = "%s = textureLod(%s, {inuv}, 0.).r;" % [out, sampler]
			"R" : # 1d from its own sampler
				if not isorm:
					s = "%s = textureLod(%s, {inuv}, 0.).g;" % [out, sampler]
			"M" : # 1d from its own sampler
				if not isorm:
					s = "%s = textureLod(%s, {inuv}, 0.).b;" % [out, sampler]
		s+="\n\n" 
		return s
	return ""
	
func _get_code(input_vars, output_vars, mode, type):
	var inuv = "UV"
	if input_vars[0]:
		inuv = input_vars[0]
	var s := ""
	for port in range(1, names.size()): #skips UV port 0
		s += create_textureLod_command(input_vars, output_vars, port)
	
	s = s.format({"inuv" : inuv})
	
	# all done, reset the isorm flag
	isorm = false
	
	return s + """
{uv_out} = {inuv};
""".format(
{
"inuv" : inuv,
"uv_out": output_vars[0],
})
