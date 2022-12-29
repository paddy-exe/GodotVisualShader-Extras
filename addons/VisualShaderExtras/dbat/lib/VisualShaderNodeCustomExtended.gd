@tool
class_name VisualShaderNodeCustomExtended
extends VisualShaderNodeCustom

# The MIT License
# Copyright (c) 2007-2022 Juan Linietsky, Ariel Manzur.
# Copyright © 2022 Donn Ingle
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


## A general store of common funcs we can recall form anywhere
## Done as a Resource to try keep duplication of these strings 
## down to, hopefully, one instance.

func _get_description_and_version(s):
	return "%s\nVersion:%s" % [s,self._get_version()]

## Code from MaterialMaker, care of Rodzilla
var compare:="""
float compare(vec4 in1, vec4 in2)
{
	return dot(abs(in1-in2), vec4(1.0));
}
"""

## Returns radians
var random_float:="""
float random_float(vec2 input) {
	return fract(sin(dot(input.xy, vec2(12.9898,78.233))) * 43758.5453123);
}"""

## From Juan Linietsky, Ariel Manzur
var hash_noise_range:="""
vec3 hash_noise_range( vec3 p ) {
	p *= mat3(vec3(127.1, 311.7, -53.7), vec3(269.5, 183.3, 77.1), vec3(-301.7, 27.3, 215.3));
	return 2.0 * fract(fract(p)*4375.55) -1.;
}"""

var vec2_rotate:="""
vec2 vec2_rotate(vec2 _uv, float _angle) {
	_uv -= 0.5;
	_uv = mat2( vec2(cos(_angle), -sin(_angle)), vec2(sin(_angle), cos(_angle)) ) * _uv;
	_uv += 0.5;
	return _uv;
}"""

## mip_map_lod
## Is a way to remove the edges on textures that are tiled
## Use:
## uniform sampler2D albedo_texture;
## float lod = mip_map_lod(UV*tiling * vec2(textureSize(albedo_texture, 0)));
## ALBEDO = textureLod(albedo_texture, some_new_uv, lod).rgb;
var mip_map_lod:="""
//Returns an "lod" according to some dark openGL voodoo
float mip_map_lod(in vec2 _uv, vec2 texture_size) {
	vec2 texture_coordinate = _uv * texture_size;
	vec2 dx_vtc = dFdx(texture_coordinate);
	vec2 dy_vtc = dFdy(texture_coordinate);
	float delta_max_sqr = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
	float mml = 0.5 * log2(delta_max_sqr);
	return max(0, mml);
}"""

var basic_uv_tile:="""
vec2 tile(vec2 _uv, float _zoom){
	_uv *= _zoom;
	return fract(_uv);
}"""

var brick_tile:="""
vec2 brick_tile(vec2 _uv, float _zoom, float _shift)
{
	_uv.x += step(1.0, mod(_uv.y, 2.0))  *  _shift;
	return fract(_uv);
}"""
