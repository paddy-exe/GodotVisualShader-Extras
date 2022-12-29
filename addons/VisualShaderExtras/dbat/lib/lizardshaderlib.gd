# The MIT License
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

class_name LizardShaderLib extends Resource

## A general store of common funcs we can recall form anywhere
## Done as a Resource to try keep duplication of these strings 
## down to, hopefully, one instance.

@export var random_float:="""
float random_float(vec2 input) {
	return fract(sin(dot(input.xy, vec2(12.9898,78.233))) * 43758.5453123);
}"""

@export var hash_noise_range:="""
vec3 hash_noise_range( vec3 p ) {
	p *= mat3(vec3(127.1, 311.7, -53.7), vec3(269.5, 183.3, 77.1), vec3(-301.7, 27.3, 215.3));
	return 2.0 * fract(fract(p)*4375.55) -1.;
}"""

@export var vec2_rotate:="""
vec2 vec2_rotate(vec2 _v2, float _angle) {
	_v2 -= 0.5;
	_v2 = mat2( vec2(cos(_angle), -sin(_angle)), vec2(sin(_angle), cos(_angle)) ) * _v2;
	_v2 += 0.5;
	return _v2;
}"""

@export var mip_map_lod:="""
float mip_map_level(in vec2 _uv, vec2 texture_size) {
	vec2 texture_coordinate = _uv * texture_size;
	vec2 dx_vtc = dFdx(texture_coordinate);
	vec2 dy_vtc = dFdy(texture_coordinate);
	float delta_max_sqr = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
	float mml = 0.5 * log2(delta_max_sqr);
	return max(0, mml);
}"""

@export var basic_uv_tile:="""
vec2 tile(vec2 _uv, float _zoom){
	_uv *= _zoom;
	return fract(_uv);
}"""

