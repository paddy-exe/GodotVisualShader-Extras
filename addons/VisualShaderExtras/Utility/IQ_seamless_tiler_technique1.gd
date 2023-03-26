@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeIQSeamlessTilingTechnique1

func _get_name():
	return "IQSeamlessTilingTechnique1"

func _get_category():
	return "VisualShaderExtras/dev"

func _get_description():
	return """https://iquilezles.org/articles/texturerepetition\nOne way to prevent the visual repetition of the texture is to assign a random offset and orientation to each tile of the repetition. We can do that by determining in which tile we are, creating a series of four pseudo-random values for the tile, and then using these to offset and re-orient the texture. Re-orientation can be something as simple as mirroring in x or y or both. This produces a non repeating pattern over the whole surface.."""

func _is_available(mode, type):
	return mode == VisualShader.MODE_SPATIAL
	
func _is_highend():
	return true #mark as PC only.

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_output_port_count():
	return 5
	
func _get_output_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		1: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2: return VisualShaderNode.PORT_TYPE_SCALAR
		3: return VisualShaderNode.PORT_TYPE_SCALAR
		4: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_name(port: int):
	match port:
		0: return "Albedo"
		1: return "Normal Map"
		2: return "AO"
		3: return "Roughness"
		4: return "Metallic"

	
func _init() -> void:
	set_input_port_default_value(0, 2.)
	
func _get_input_port_count():
	return 4

func _get_input_port_name(port):
	match port:
		0: return "UV Scale"
		1: return "Albedo"
		2: return "Normal Map"
		3: return "ORM"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_SCALAR 
		1: return VisualShaderNode.PORT_TYPE_SAMPLER
		2: return VisualShaderNode.PORT_TYPE_SAMPLER
		3: return VisualShaderNode.PORT_TYPE_SAMPLER

func _get_global_code(mode):
	return """
// The MIT License
// Copyright © 2015 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

vec4 hash4_VisualShaderNodeIQSeamlessTilingTechnique1( vec2 p ) { return fract(sin(vec4( 1.0+dot(p,vec2(37.0,17.0)), 
											  2.0+dot(p,vec2(11.0,47.0)),
											  3.0+dot(p,vec2(41.0,29.0)),
											  4.0+dot(p,vec2(23.0,31.0))))*103.0); }

vec4 textureNoTile_VisualShaderNodeIQSeamlessTilingTechnique1( sampler2D samp, in vec2 uv )
{
	
	// OK
	vec2 iuv = floor( uv );
	vec2 fuv = fract( uv );
	vec4 ofa = hash4_VisualShaderNodeIQSeamlessTilingTechnique1( iuv + vec2(0.0,0.0) );
	vec4 ofb = hash4_VisualShaderNodeIQSeamlessTilingTechnique1( iuv + vec2(1.0,0.0) );
	vec4 ofc = hash4_VisualShaderNodeIQSeamlessTilingTechnique1( iuv + vec2(0.0,1.0) );
	vec4 ofd = hash4_VisualShaderNodeIQSeamlessTilingTechnique1( iuv + vec2(1.0,1.0) );
	
	vec2 ddx = dFdx( uv );
	vec2 ddy = dFdy( uv );
	
	// transform per-tile uvs
	ofa.zw = sign(ofa.zw-0.5);
	ofb.zw = sign(ofb.zw-0.5);
	ofc.zw = sign(ofc.zw-0.5);
	ofd.zw = sign(ofd.zw-0.5);
	
	// uv's, and derivarives (for correct mipmapping)
	vec2 uva = uv*ofa.zw + ofa.xy; vec2 ddxa = ddx*ofa.zw; vec2 ddya = ddy*ofa.zw;
	vec2 uvb = uv*ofb.zw + ofb.xy; vec2 ddxb = ddx*ofb.zw; vec2 ddyb = ddy*ofb.zw;
	vec2 uvc = uv*ofc.zw + ofc.xy; vec2 ddxc = ddx*ofc.zw; vec2 ddyc = ddy*ofc.zw;
	vec2 uvd = uv*ofd.zw + ofd.xy; vec2 ddxd = ddx*ofd.zw; vec2 ddyd = ddy*ofd.zw;
	
	// fetch and blend
	vec2 b = smoothstep(0.25,0.75,fuv);
	return mix( mix( textureGrad( samp, uva, ddxa, ddya ), 
					 textureGrad( samp, uvb, ddxb, ddyb ), b.x ), 
				mix( textureGrad( samp, uvc, ddxc, ddyc ),
					 textureGrad( samp, uvd, ddxd, ddyd ), b.x), b.y );
}"""

func _get_code(input_vars, output_vars, mode, type):
	var foo = """
	vec2 uv = UV * {UV_SCALE_in};
	NORMAL_MAP_DEPTH = 3.0;
	"""
	
	if input_vars[1]: 
		foo += """{ALBEDO_out} = textureNoTile_VisualShaderNodeIQSeamlessTilingTechnique1({ALBEDO_in}, uv).rgb;"""
	if input_vars[2]: 
		foo += """{NM_out} = textureNoTile_VisualShaderNodeIQSeamlessTilingTechnique1({NM_in}, uv).rgb;"""
	if input_vars[3]: 
		foo += """{O_out} = textureNoTile_VisualShaderNodeIQSeamlessTilingTechnique1({O_in}, uv).r;"""
		foo += """{R_out} = textureNoTile_VisualShaderNodeIQSeamlessTilingTechnique1({O_in}, uv).g;"""
		foo += """{M_out} = textureNoTile_VisualShaderNodeIQSeamlessTilingTechnique1({O_in}, uv).b;"""
	foo = foo.format(
	{
		"UV_SCALE_in": input_vars[0],
		"ALBEDO_in": input_vars[1],
		"NM_in": input_vars[2],
		"O_in": input_vars[3],
		
		"ALBEDO_out": output_vars[0],
		"NM_out": output_vars[1],
		"O_out": output_vars[2],
		"R_out": output_vars[3],
		"M_out": output_vars[4],
	})
	return foo
