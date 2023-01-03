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

extends RefCounted
class_name LizardShaderLibrary

const foo:="FOO"

## The Lizard Shader Library
## A general store of common funcs we can recall form anywhere
## This is Refcounted and uses consts so these strings exist only once.
##
## Use:
## In any other code simply call:
## LizardShaderLibrary.__whatever__ <-- func or string

static func format_description(obj:Object, desc:String)->String:
	return "%s\nVersion:%s\n%s" % [
		desc,
		obj._get_version(),
		"Issues:%s" % [obj._get_issues() if obj.has_method("_get_issues") else "None" ]
	]

## Code from MaterialMaker, care of Rodzilla
const compare:="""
float compare(vec4 in1, vec4 in2, float fuzz)
{
	return dot(abs(in1-in2), vec4(fuzz));
}
"""

## Returns float from 0.0 to 1.0
const random_float:="""
float random_float(vec2 input) {
	return fract(sin(dot(input.xy, vec2(12.9898,78.233))) * 43758.5453123);
}"""

## From Juan Linietsky, Ariel Manzur
const hash_noise_range:="""
vec3 hash_noise_range( vec3 p ) {
	p *= mat3(vec3(127.1, 311.7, -53.7), vec3(269.5, 183.3, 77.1), vec3(-301.7, 27.3, 215.3));
	return 2.0 * fract(fract(p)*4375.55) -1.;
}"""

## _angle in radians
const vec2_rotate:="""
vec2 vec2_rotate(vec2 _uv, float _angle, vec2 _pivot) {
	_uv -= _pivot;
	_uv = mat2( vec2(cos(_angle), -sin(_angle)), vec2(sin(_angle), cos(_angle)) ) * _uv;
	_uv += _pivot;
	return _uv;
}"""

## mip_map_lod
## Is a way to remove the edges on textures that are tiled
## Use:
## uniform sampler2D albedo_texture;
## float lod = mip_map_lod(UV*tiling * vec2(textureSize(albedo_texture, 0)));
## ALBEDO = textureLod(albedo_texture, some_new_uv, lod).rgb;
const mip_map_lod:="""
//Returns an "lod" according to some dark openGL voodoo
float mip_map_lod(in vec2 _uv, vec2 texture_size) {
	vec2 texture_coordinate = _uv * texture_size;
	vec2 dx_vtc = dFdx(texture_coordinate);
	vec2 dy_vtc = dFdy(texture_coordinate);
	float delta_max_sqr = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
	float mml = 0.5 * log2(delta_max_sqr);
	return max(0, mml);
}"""

const basic_uv_tile:="""
vec2 tile(vec2 _uv, float _zoom){
	_uv *= _zoom;
	return fract(_uv);
}"""

const brick_tile:="""
vec2 brick_tile(vec2 _uv, float _zoom, float _shift)
{
	_uv.x += step(1.0, mod(_uv.y, 2.0))  *  _shift;
	return fract(_uv);
}"""

const normal_map_add_z := """
// Godot strips the z value from imported Normal Maps.
// It does this for two reasons:
// 1. Obtaining better compression because the z can be calculated by shader.
//    Compression boosts speed of CPU to GPU transfer.
// 2. On mobile devices they do not do that calculation. They either ignore the z
//    or do some other calculation, but the normal one (below) is apparently too slow
//    or power-hungry for mobile devices.
//
// Create the texture to pass in like this:
//  vec3 normal_map_texture = textureLod(normal_texture_sampler, inuv, 0.).rgb;
vec3 normal_map_add_z(
	vec3 normal_map_texture, 
	vec2 inuv,
	vec3 _TANGENT,
	vec3 _BINORMAL,
	vec3 _NORMAL) {
	// 2022 Kasper Arnklit Frandsen - Public Domain - No Rights Reserved

	// Unpack the background normal map.
	vec3 bg_normal = normal_map_texture * 2.0 - 1.0;

	// Recalculate z-component of the normal map with the Pythagorean theorem.
	bg_normal.z = sqrt(1.0 - bg_normal.x * bg_normal.x - bg_normal.y * bg_normal.y);

	// Apply the tangent-space normal map to the view-space normals.
	vec3 normal_applied = bg_normal.x * _TANGENT + bg_normal.y * _BINORMAL + bg_normal.z * _NORMAL;
	return normal_applied;
}
"""

const world_normal_mask := """
// Create the texture to pass in like this:
//  vec3 normal_map_texture = textureLod(normal_texture_sampler, inuv, 0.).rgb;
float world_normal_mask(
	vec3 normal_map_texture, 
	vec3 vector_direction,
	mat4 _VIEW_MATRIX
	) {
	// 2022 Kasper Arnklit Frandsen - Public Domain - No Rights Reserved
	// Convert the world up vector into view-space with a matrix multiplication.
	vec3 up_vector_viewspace = mat3(_VIEW_MATRIX) * vector_direction;

	// Compare the up vector to the surface with the normal map applied using the dot product.
	float dot_product = dot(up_vector_viewspace, normal_map_texture);

	return dot_product;
}
"""

const mask_blend := """
float mask_blend(float offset, float fade, float mask_in) {
	offset *= -1.;

	// 2022 Kasper Arnklit Frandsen - Public Domain - No Rights Reserved
	return smoothstep(offset - fade, offset + fade, mask_in);
}
"""
