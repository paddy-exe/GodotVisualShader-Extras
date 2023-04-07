# The MIT License
# Copyright © 2022 Donn Ingle (on shoulders of giants)
# Copyright (c) 2022 mmikk, yaelatletl
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
class_name VisualShaderNodeSeamlessTiling

func _get_name():
	return "SeamlessTiling"

func _get_category():
	return "VisualShaderExtras/dev"

func _get_description():
	return """..."""

func _is_available(mode, type):
	return mode == VisualShader.MODE_SPATIAL
	
func _is_highend():
	return true #mark as PC only.

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SAMPLER

func _get_output_port_count():
	return 6
	
func _get_output_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		1: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2: return VisualShaderNode.PORT_TYPE_SCALAR
		3: return VisualShaderNode.PORT_TYPE_SCALAR
		4: return VisualShaderNode.PORT_TYPE_SCALAR
		5: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_name(port: int):
	match port:
		0: return "Albedo"
		1: return "Normal Map"
		2: return "AO"
		3: return "Roughness"
		4: return "Metallic"
		5: return "Specular"

	
func _init() -> void:
	set_input_port_default_value(6, 0.)
	set_input_port_default_value(7, 0.)
	set_input_port_default_value(8, 0.)
	set_input_port_default_value(14, 0.25)
	set_input_port_default_value(15, 0.35)
	
func _get_input_port_count():
	return 1

func _get_input_port_name(port):
	match port:
		0: return "Top Base Sampler"
		1: return "Top Normal Map Sampler"
		2: return "Top ORM Sampler"
		3: return "Side Base Sampler"
		4: return "Side Normal Map Sampler"
		5: return "Side ORM Sampler"
		6: return "Metallic"
		7: return "Roughness"
		8: return "Light Affect"
		9: return "UV1 Blend Sharpness"
		10: return "UV1 Scale"
		11: return "UV1 Offset"
		12: return "UV2 Scale"
		13: return "UV2 Offset"
		14: return "Sides Smoothing"
		15: return "Top Smoothing"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_SAMPLER
		1: return VisualShaderNode.PORT_TYPE_SAMPLER
		2: return VisualShaderNode.PORT_TYPE_SAMPLER 
		3: return VisualShaderNode.PORT_TYPE_SAMPLER
		4: return VisualShaderNode.PORT_TYPE_SAMPLER
		5: return VisualShaderNode.PORT_TYPE_SAMPLER
		
		6: return VisualShaderNode.PORT_TYPE_SCALAR
		7: return VisualShaderNode.PORT_TYPE_SCALAR
		8: return VisualShaderNode.PORT_TYPE_SCALAR
		
		9: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		10: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		11: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		12: return VisualShaderNode.PORT_TYPE_VECTOR_3D

		13: return VisualShaderNode.PORT_TYPE_SCALAR
		14: return VisualShaderNode.PORT_TYPE_SCALAR
				
func _get_func_code(mode , type):
	var vertcode:String
	if type == VisualShader.TYPE_VERTEX:
		vertcode = """
//uniform float displacement_strength = 0.5;
	TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	BINORMAL = vec3(0.0,1.0,0.0) * abs(NORMAL.x);
	BINORMAL+= vec3(0.0,0.0,-1.0) * abs(NORMAL.y);
	BINORMAL+= vec3(0.0,1.0,0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);
	uv1_power_normal=pow(abs(NORMAL),vec3(uv1_blend_sharpness));
	uv1_power_normal/=dot(uv1_power_normal,vec3(1.0));
	uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
	uv1_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	//float displace = triplanar_texture_argh(top_displace,side_displace,uv1_power_normal,uv1_triplanar_pos).r;
	//VERTEX += NORMAL * displace * displacement_strength;
"""		
	return vertcode
	
func _get_global_code(mode):
	return """
//MIT License
//
//Copyright (c) 2022 mmikk, yaelatletl
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
//Hextiling terrain shader for Godot Engine, based on: https://github.com/mmikk/hextile-demo
//ported from HLSL by Yael Atletl

//shader_type spatial;
//render_mode blend_mix;

const float FLT_EPSILON = 1.192092896e-07F;
const float M_PI = 3.141592;

uniform sampler2D top_normal_map : hint_normal;
uniform sampler2D top_base_color : source_color;
uniform sampler2D top_ORM;
uniform sampler2D side_base_color : source_color;
uniform sampler2D side_normal_map : hint_normal;
uniform sampler2D side_ORM;
//uniform sampler2D top_displace: hint_white;
//uniform sampler2D side_displace : hint_white;
uniform float metallic = 0.0;
uniform float roughness = 0.0;
uniform float light_affect = 0.0;
uniform float uv1_blend_sharpness;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform float sides_smoothing = 0.25;
uniform float top_smoothing = 0.35;
	
varying vec3 uv1_power_normal;
varying vec3 sigmaX;
varying vec3 sigmaY;
varying vec3 nrmBaseNormal;
varying vec3 dPdx;
varying vec3 dPdy;
varying float  flip_sign;
// Used for vertex-level tangent space (one UV set only).
varying vec3 mikktsTangent;
varying vec3 mikktsBitangent;
varying vec3 uv1_triplanar_pos;

vec2 frac(vec2 texin){
	return vec2(texin.x - floor(texin.x), texin.y-floor(texin.y));
}

vec3 ResolveNormalFromSurfaceGradient(vec3 surfGrad)
{
	return normalize(nrmBaseNormal - surfGrad);
}

// Input: vM is tangent space normal in [-1;1].
// Output: convert vM to a derivative.
vec2 TspaceNormalToDerivative(vec3 vM)
{
	const float scale = 1.0/128.0;

	// Ensure vM delivers a positive third component using abs() and
	// constrain vM.z so the range of the derivative is [-128; 128].
	vec3 vMa = abs(vM);
	float z_ma = max(vMa.z, scale*max(vMa.x, vMa.y));

	// Set to match positive vertical texture coordinate axis.
	const bool gFlipVertDeriv = true;
	const float s = gFlipVertDeriv ? -1.0 : 1.0;
	return -vec2(vM.x, s*vM.y)/z_ma;
}

vec3 SurfgradFromTBN(vec2 deriv, vec3 vT, vec3 vB)
{
	return deriv.x*vT + deriv.y*vB;
}

void GenBasisTB(out vec3 vT, out vec3 vB, vec2 texST)
{
	vec2 dSTdx = dFdx(texST);
	vec2 dSTdy = dFdy(texST);
	float det = dot(dSTdx, vec2(dSTdy.y, -dSTdy.x));
	float sign_det = det < 0.0 ? -1.0 : 1.0;
 
	// invC0 represents (dXds, dYds), but we don't divide
	// by the determinant. Instead, we scale by the sign.
	vec2 invC0 = sign_det*vec2(dSTdy.y, -dSTdx.y); 
	vT = sigmaX*invC0.x + sigmaY*invC0.y;
	if (abs(det) > 0.0) vT = normalize(vT);
	vB = (sign_det*flip_sign)*cross(nrmBaseNormal, vT);
}

// Surface gradient from a known "normal" such as from an object-
// space normal map. This allows us to mix the contribution with
// others, including from tangent-space normals. The vector v
// doesn't need to be unit length so long as it establishes
// the direction. It must also be in the same space as the normal.
vec3 SurfgradFromPerturbedNormal(vec3 v)
{
	// If k is negative then we have an inward facing vector v,
	// so we negate the surface gradient to perturb toward v.
	vec3 n = nrmBaseNormal;
	float k = dot(n, v);
	return (k*n - v)/max(FLT_EPSILON, abs(k));
}

// dim: resolution of the texture deriv was sampled from.
// isDerivScreenSpace: true if deriv is already in screen space.
vec3 SurfgradScaleDependent(vec2 deriv, vec2 texST, ivec2 dim, bool isDerivScreenSpace) //= false
{
	// Convert derivative to normalized (s,t) space.
	vec2 dHdST = vec2(dim) * deriv;

	// Convert derivative to screen space by applying
	// the chain rule. dHdx and dHdy correspond to
	// dFdx_fine(height) and dFdy_fine(height).
	vec2 texDx = dFdx(texST);
	vec2 texDy = dFdy(texST);
	float dHdx = dHdST.x*texDx.x + dHdST.y*texDx.y;
	float dHdy = dHdST.x*texDy.x + dHdST.y*texDy.y;

	if (isDerivScreenSpace)
	{
		dHdx = deriv.x;
		dHdy = deriv.y; 
	}

	// Eq.3 in "Bump Mapping Unparametrized Surfaces on the GPU".
	vec3 vR1 = cross(dPdy, nrmBaseNormal);
	vec3 vR2 = cross(nrmBaseNormal, dPdx);
	float det = dot(dPdx, vR1);

	const float eps = 1.192093e-15F;
	float sign_det = det < 0.0 ? -1.0 : 1.0;
	float s = sign_det/max(eps, abs(det));

	return s*(dHdx*vR1 + dHdy*vR2);
}


// Used to produce a surface gradient from the gradient of a volume
// bump function such as 3D Perlin noise. Equation 2 in [Mik10].
vec3 SurfgradFromVolumeGradient(vec3 grad)
{
	return grad - dot(nrmBaseNormal, grad)*nrmBaseNormal;
}


// Triplanar projection is considered a special case of volume
// bump map. Weights are obtained using DetermineTriplanarWeights()
// and derivatives using TspaceNormalToDerivative().
vec3 SurfgradFromTriplanarProjection(vec3 triplanarWeights, vec2 deriv_xplane, vec2 deriv_yplane, vec2 deriv_zplane)
{
	float w0 = triplanarWeights.x;
	float w1 = triplanarWeights.y;
	float w2 = triplanarWeights.z;
	
	// Assume deriv_xplane, deriv_yplane, and deriv_zplane are
	// sampled using (z,y), (x,z), and (x,y), respectively.
	// Positive scales of the lookup coordinate will work
	// as well, but for negative scales the derivative components
	// will need to be negated accordingly.
	vec3 grad = vec3(w2*deriv_zplane.x + w1*deriv_yplane.x,
						w2*deriv_zplane.y + w0*deriv_xplane.y,
						w0*deriv_xplane.x + w1*deriv_yplane.y);

	return SurfgradFromVolumeGradient(grad);
}

// Adapted from
// http://www.slideshare.net/icastano/cascades-demo-secrets.
vec3 DetermineTriplanarWeights(float k )//= 3.0
{
	vec3 weights = abs(nrmBaseNormal) - 0.2;
	weights = max(weights, 0);
	weights = pow(weights, vec3(k));
	weights /= (weights.x + weights.y + weights.z);
	return weights;
}


float CalculateLevelOfDetail(){ //samp, texST
	return 1.0;
}


// Returns dHduv where (u,v) is in pixel units at the top MIP level.
vec2 DerivFromHeightMap(sampler2D samp, vec2 texST, bool isUpscaleHQ) // = false
{
	float lod = CalculateLevelOfDetail();
	ivec2 dim = textureSize(samp, int(lod));
	vec2 onePixOffs = vec2(1.0/float(dim.x), 1.0/float(dim.y));
	float eoffs = exp2(lod);
	vec2 actualOffs = onePixOffs*eoffs;
	vec2 st_r = texST + vec2(actualOffs.x, 0.0);
	vec2 st_u = texST + vec2(0.0, actualOffs.y);

	float Hr = texture(samp, st_r).x;
	float Hu = texture(samp, st_u).x;
	float Hc = texture(samp, texST).x;
	vec2 dHduv = vec2(Hr - Hc, Hu - Hc)/eoffs;
	float start = 0.5, end = 0.05; // start-end fade
	float mixd = clamp((lod - start)/(end - start), 0.0, 1.0);

	if (isUpscaleHQ && mixd > 0.0)
	{
		vec2 f2TexCoord = vec2(dim)*texST - vec2(0.5, 0.5);
		vec2 f2FlTexCoord = floor(f2TexCoord);
		vec2 t = clamp(f2TexCoord - f2FlTexCoord, 0.0, 1.0);
		vec2 cenST = (f2FlTexCoord + vec2(0.5, 0.5))/vec2(dim);
		vec4 sampUL = texelFetch(samp, ivec2(cenST + vec2(-1,-1)), int(lod));
		vec4 sampUR = texelFetch(samp, ivec2(cenST + vec2( 1,-1)), int(lod));
		vec4 sampLL = texelFetch(samp, ivec2(cenST + vec2(-1, 1)), int(lod));
		vec4 sampLR = texelFetch(samp, ivec2(cenST + vec2( 1, 1)), int(lod));
		
		// vec4(UL.wz, UR.wz) represents first scanline and so on.
		mat4 H = mat4(
					vec4(sampUL.w, sampUL.z, sampUR.w, sampUR.z), 
					vec4(sampUL.x, sampUL.y, sampUR.x, sampUR.y),
					vec4(sampLL.w, sampLL.z, sampLR.w, sampLR.z),
					vec4(sampLL.x, sampLL.y, sampLR.x, sampLR.y));

		vec2 A = vec2(1.0 - t.x, t.x);
		vec2 B = vec2(1.0 - t.y, t.y);
		vec4 X = 0.25*vec4(A.x, 2.0*A.x + A.y, A.x + 2.0*A.y, A.y);
		vec4 Y = 0.25*vec4(B.x, 2.0*B.x + B.y, B.x + 2.0*B.y, B.y);
		vec4 dX = 0.5*vec4(-A.x, -A.y, A.x, A.y);
		vec4 dY = 0.5*vec4(-B.x, -B.y, B.x, B.y);
		vec2 dHduv_ups = vec2(dot( Y, H*dX), dot(dY, H*X));
		dHduv = mix(dHduv, dHduv_ups, mixd);
	}

	return dHduv;
}


// Returns dHduv where (u,v) is in pixel units at the top MIP level.
vec2 DerivFromHeightMapLevel(sampler2D samp, vec2 texST, float lod_in, bool isUpscaleHQ) //=false
{
	ivec2 dim = textureSize(samp, int(CalculateLevelOfDetail()));
	vec2 onePixOffs = vec2(1.0/float(dim.x), 1.0/float(dim.y));
	float lod = max(0.0, lod_in);
	float eoffs = exp2(lod);
	vec2 actualOffs = onePixOffs*eoffs;
	vec2 st_r = texST + vec2(actualOffs.x, 0.0);
	vec2 st_u = texST + vec2(0.0, actualOffs.y);

	float Hr = textureLod(samp, st_r, lod).x;
	float Hu = textureLod(samp, st_u, lod).x;
	float Hc = textureLod(samp, texST, lod).x;
	vec2 dHduv = vec2(Hr - Hc, Hu - Hc)/eoffs;
	float start = 0.5, end = 0.05; // start-end fade
	float mixd = clamp((lod - start)/(end - start), 0.0, 1.0);

	if (isUpscaleHQ && mixd > 0.0)
	{
		vec2 f2TexCoord = vec2(dim)*texST - vec2(0.5, 0.5);
		vec2 f2FlTexCoord = floor(f2TexCoord);
		vec2 t = clamp(f2TexCoord - f2FlTexCoord, 0.0, 1.0);
		vec2 cenST = (f2FlTexCoord + vec2(0.5, 0.5))/vec2(dim);
		vec4 sampUL = texelFetch(samp, ivec2(cenST+ vec2(-1,-1)), 1);
		vec4 sampUR = texelFetch(samp, ivec2(cenST+ vec2( 1,-1)), 1);
		vec4 sampLL = texelFetch(samp, ivec2(cenST+ vec2(-1, 1)), 1);
		vec4 sampLR = texelFetch(samp, ivec2(cenST+ vec2( 1, 1)), 1);
		
		// vec4(UL.wz, UR.wz) represents first scanline and so on.
		mat4 H = mat4(
					vec4(sampUL.w, sampUL.z, sampUR.w, sampUR.z),
					vec4(sampUL.x, sampUL.y, sampUR.x, sampUR.y),
					vec4(sampLL.w, sampLL.z, sampLR.w, sampLR.z),
					vec4(sampLL.x, sampLL.y, sampLR.x, sampLR.y));

		vec2 A = vec2(1.0 - t.x, t.x);
		vec2 B = vec2(1.0 - t.y, t.y);
		vec4 X = 0.25*vec4(A.x, 2.0*A.x + A.y, A.x + 2.0*A.y, A.y);
		vec4 Y = 0.25*vec4(B.x, 2.0*B.x + B.y, B.x + 2.0*B.y, B.y);
		vec4 dX = 0.5*vec4(-A.x, -A.y, A.x, A.y);
		vec4 dY = 0.5*vec4(-B.x, -B.y, B.x, B.y);
		vec2 dHduv_ups = vec2(dot( Y, H*dX), dot(dY, H*X));
		dHduv = mix(dHduv, dHduv_ups, mixd);
	}

	return dHduv;
}


// fix backward facing normal
vec3 FixNormal(vec3 N, vec3 V)
{
	return dot(N,V)>=0.0 ? N : (N-2.0*dot(N,V)*V);
}



// dir: normalized vector in same space as surface pos and normal.
// bumpScale: p' = p + bumpScale*DisplacementMap(s,t)*normal.
vec2 ProjectVecToTextureSpace(vec3 dir, vec2 texST, float bumpScale, bool skipProj) // = false
{
	vec2 texDx = dFdx(texST);
	vec2 texDy = dFdy(texST);
	vec3 vR1 = cross(dPdy, nrmBaseNormal);
	vec3 vR2 = cross(nrmBaseNormal, dPdx);
	float  det = dot(dPdx, vR1);

	const float eps = 1.192093e-15F;
	float sgn = det < 0.0 ? -1.0 : 1.0;
	float s = sgn/max(eps, abs(det));

	vec2 dirScr  = s*vec2(dot(vR1, dir), dot(vR2, dir));
	vec2 dirTex  = texDx*dirScr.x + texDy*dirScr.y;
	float  dirTexZ = dot(nrmBaseNormal, dir);

	// To search heights in [0;1] range use dirTex.xy/dirTexZ.
	s = skipProj ? 1.0 : 1.0/max(FLT_EPSILON, abs(dirTexZ));
	return s*bumpScale*dirTex;
}

// initialST: initial texture coordinate before parallax correction.
// corrOffs: parallax-corrected offset from initialST.
vec3 TexSpaceOffsToSurface(vec2 initialST, vec2 corrOffs)
{
	vec2 texDx = dFdx(initialST);
	vec2 texDy = dFdy(initialST);
	float det = texDx.x*texDy.y - texDx.y*texDy.x;

	const float eps = 1.192093e-15F;
	float sgn = det < 0.0 ? -1.0 : 1.0;
	float s = sgn/max(eps, abs(det));

	// Transform corrOffs from texture space to screen space.
	// Use 2x2 inverse of [dFdx(initialST) | dFdy(initialST)]
	float vx = s*( texDy.y*corrOffs.x - texDy.x*corrOffs.y);
	float vy = s*(-texDx.y*corrOffs.x + texDx.x*corrOffs.y);

	// Transform screen-space vector to the surface.
	return vx*sigmaX + vy*sigmaY;
}


uniform float g_fallOffContrast = 0.6;
uniform float g_exp = 7;

// Output: weights associated with each hex tile and integer centers
void TriangleGrid(out float w1, out float w2, out float w3, 
				  out ivec2 vertex1, out ivec2 vertex2, out ivec2 vertex3,
				  vec2 st)
{
	// Scaling of the input
	st *= 2.0 * sqrt(3);

	// Skew input space into simplex triangle grid
	const mat2 gridToSkewedGrid = 
		mat2(vec2(1.0, -0.57735027), vec2( 0.0, 1.15470054));
	vec2 skewedCoord = gridToSkewedGrid*st;

	ivec2 baseId = ivec2( floor ( skewedCoord ));
	vec3 temp = vec3( frac( skewedCoord ), 0);
	temp.z = 1.0 - temp.x - temp.y;

	float s = step(0.0, -temp.z);
	float s2 = 2.0*s-1.0;

	w1 = -temp.z*s2;
	w2 = s - temp.y*s2;
	w3 = s - temp.x*s2;

	vertex1 = baseId + ivec2(int(s));
	vertex2 = baseId + ivec2(int(s),int(1.0-s));
	vertex3 = baseId + ivec2(int(1.0-s),int(s));
}

float fmod(float x, float y){
	return x - y * trunc(x/y);
}
vec2 hash(ivec2 p)
{
	vec2 r = mat2(vec2(127.1, 311.7),vec2(269.5, 183.3))*vec2(p);
	
	return frac( sin( r )*43758.5453 );
}

vec2 sampleDeriv(sampler2D samp, vec2 st, vec2 dSTdx, vec2 dSTdy)
{
	// sample
	vec3 vM = 2.0*textureGrad(samp, st, dSTdx, dSTdy).rgb-1.0;
	return TspaceNormalToDerivative(vM);
}

mat2 LoadRot2x2(ivec2 idx, float rotStrength)
{
	float angle = float(abs(idx.x*idx.y)) + float(abs(idx.x+idx.y)) + M_PI;

	// remap to +/-pi
	angle = fmod(angle, 2.0*M_PI); 
	if(angle<0.0) angle += 2.0*M_PI;
	if(angle>M_PI) angle -= 2.0*M_PI;

	angle *= rotStrength;

	float cs = cos(angle), si = sin(angle);

	return mat2(vec2(cs, -si),vec2(si, cs));
}
vec2 MakeCenST(ivec2 Vertex)
{
	mat2 invSkewMat = mat2(vec2(1.0, 0.5), vec2(0.0, 1.0/1.15470054));

	return (invSkewMat * vec2(Vertex)) / (2.0 * sqrt(3.0));
}

vec3 Gain3(vec3 x, float r)
{
	// increase contrast when r>0.5 and
	// reduce contrast if less
	float k = log(1.0-r) / log(0.5);

	vec3 s = 2.0*step(0.5, x);
	vec3 m = 2.0*(1.0 - s);

	vec3 res = 0.5*s + 0.25*m * pow(max(vec3(0.0), s + x*m), vec3(k));
	
	return res.xyz / (res.x+res.y+res.z);
}



vec3 ProduceHexWeights(vec3 W, ivec2 vertex1, ivec2 vertex2, ivec2 vertex3)
{
	vec3 res = vec3(0.0);

	int v1 = (vertex1.x-vertex1.y)%3;
	if(v1<0) v1+=3;

	int vh = v1<2 ? (v1+1) : 0;
	int vl = v1>0 ? (v1-1) : 2;
	int v2 = vertex1.x<vertex3.x ? vl : vh;
	int v3 = vertex1.x<vertex3.x ? vh : vl;

	res.x = v3==0 ? W.z : (v2==0 ? W.y : W.x);
	res.y = v3==1 ? W.z : (v2==1 ? W.y : W.x);
	res.z = v3==2 ? W.z : (v2==2 ? W.y : W.x);

	return res;
}

// Input: nmap is a normal map
// Input: r increase contrast when r>0.5
// Output: deriv is a derivative dHduv wrt units in pixels
// Output: weights shows the weight of each hex tile
void bumphex2derivNMap(out vec2 deriv, out vec3 weights,
						sampler2D samp, vec2 st,
					   float rotStrength, float r) //=0.5
{
	vec2 dSTdx = dFdx(st);
	vec2 dSTdy = dFdy(st);

	// Get triangle info
	float w1, w2, w3;
	ivec2 vertex1, vertex2, vertex3;
	TriangleGrid(w1, w2, w3, vertex1, vertex2, vertex3, st);

	mat2 rot1 = LoadRot2x2(vertex1, rotStrength);
	mat2 rot2 = LoadRot2x2(vertex2, rotStrength);
	mat2 rot3 = LoadRot2x2(vertex3, rotStrength);

	vec2 cen1 = MakeCenST(vertex1);
	vec2 cen2 = MakeCenST(vertex2);
	vec2 cen3 = MakeCenST(vertex3);

	vec2 st1 = (st - cen1)* rot1 + cen1 + hash(vertex1);
	vec2 st2 = (st - cen2)* rot2 + cen2 + hash(vertex2);
	vec2 st3 = (st - cen3)* rot3 + cen3 + hash(vertex3);

	// Fetch input
	vec2 d1 = sampleDeriv(samp, st1, 
							(dSTdx* rot1), (dSTdy* rot1));
	vec2 d2 = sampleDeriv(samp, st2, 
							(dSTdx* rot2), (dSTdy* rot2));
	vec2 d3 = sampleDeriv(samp, st3, 
							(dSTdx* rot3), (dSTdy* rot3));

	d1 = (rot1* d1); d2 = (rot2* d2); d3 = (rot3* d3);

	// produce sine to the angle between the conceptual normal
	// in tangent space and the Z-axis
	vec3 D = vec3( dot(d1,d1), dot(d2,d2), dot(d3,d3));
	vec3 Dw = sqrt(D/(1.0+D));
	
	Dw = mix(vec3(1.0), Dw, g_fallOffContrast);	// 0.6
	vec3 W = Dw*vec3(pow(w1,g_exp), pow(w2,g_exp), pow(w3, g_exp));	// 7
	W /= (W.x+W.y+W.z);
	if(r!=0.5) W = Gain3(W, r);

	deriv = W.x * d1 + W.y * d2 + W.z * d3;
	weights = ProduceHexWeights(W.xyz, vertex1, vertex2, vertex3);
}


// Input: tex is a texture with color
// Input: r increase contrast when r>0.5
// Output: color is the blended result
// Output: weights shows the weight of each hex tile
void hex2colTex(out vec4 color, out vec3 weights,
				sampler2D samp, vec2 st,
				float rotStrength, float r)//=0.5
{
	vec2 dSTdx = dFdx(st), dSTdy = dFdy(st);

	// Get triangle info
	float w1, w2, w3;
	ivec2 vertex1, vertex2, vertex3;
	TriangleGrid(w1, w2, w3, vertex1, vertex2, vertex3, st);

	mat2 rot1 = LoadRot2x2(vertex1, rotStrength);
	mat2 rot2 = LoadRot2x2(vertex2, rotStrength);
	mat2 rot3 = LoadRot2x2(vertex3, rotStrength);

	vec2 cen1 = MakeCenST(vertex1);
	vec2 cen2 = MakeCenST(vertex2);
	vec2 cen3 = MakeCenST(vertex3);

	vec2 st1 = (st - cen1* rot1) + cen1 + hash(vertex1);
	vec2 st2 = (st - cen2* rot2) + cen2 + hash(vertex2);
	vec2 st3 = (st - cen3* rot3) + cen3 + hash(vertex3);

	// Fetch input
	vec4 c1 = textureGrad(samp, st1, 
							   (dSTdx* rot1), (dSTdy* rot1));
	vec4 c2 = textureGrad(samp, st2,
							   (dSTdx* rot2), (dSTdy* rot2));
	vec4 c3 = textureGrad(samp, st3, 
							   (dSTdx* rot3), (dSTdy* rot3));

	// use luminance as weight
	vec3 Lw = vec3(0.299, 0.587, 0.114);
	vec3 Dw = vec3(dot(c1.xyz,Lw),dot(c2.xyz,Lw),dot(c3.xyz,Lw));
	
	Dw = mix(vec3(1.0), Dw, g_fallOffContrast);	// 0.6
	vec3 W = Dw*pow(vec3(w1, w2, w3), vec3(g_exp));	// 7
	W /= (W.x+W.y+W.z);
	if(r!=0.5) W = Gain3(W, r);

	color = W.x * c1 + W.y * c2 + W.z * c3;
	weights = ProduceHexWeights(W.xyz, vertex1, vertex2, vertex3);
}


vec4 triplanar_texture_argh(sampler2D top_sampler,sampler2D side_sampler,vec3 p_weights,vec3 p_triplanar_pos) {
	// the following variables are left for reference
	//vec3 sp =  uv1_triplanar_pos; //bit of a headache, but much better than the previous method.
	//vec2 st0 = vec2(sp.x, sp.z);	//top coordinates
	//vec2 st1 = vec2(sp.x, sp.y);	//side1 coordinates
	//vec2 st2 = vec2(sp.z, sp.y);	//side2 coordinates
	vec4 samp=vec4(0.0);
	vec4 temp_samp = vec4(0.0);
	vec3 weights;
	hex2colTex(temp_samp, weights, top_sampler, uv1_triplanar_pos.xz, 1.0, 0.5);
	//temp_samp.rgb = weights;
	samp+= temp_samp* smoothstep((p_weights.z +p_weights.x-p_weights.y), 1.0, top_smoothing);
	hex2colTex(temp_samp, weights, side_sampler, uv1_triplanar_pos.zy, 1.0, 0.5);
	//temp_samp.rgb = weights;
	samp += temp_samp *smoothstep((-p_weights.x+p_weights.z+p_weights.y), 1.0, sides_smoothing);
	float eh = 10.0*(-(-p_weights.x+p_weights.z+p_weights.y)*-(p_weights.x-p_weights.z+p_weights.y))*-(p_weights.z +p_weights.x-p_weights.y);
	eh = eh*float(eh<0.02); //weighting blind spots, 3d math why
	hex2colTex(temp_samp, weights, side_sampler, uv1_triplanar_pos.xy, 1.0, 0.5);
	//temp_samp.rgb = weights;
	samp += temp_samp * smoothstep((p_weights.x-p_weights.z+p_weights.y)+eh, 1.0, sides_smoothing);
	samp = normalize(samp); //normalize this additive mess 
	return samp;
}	
	
	"""

func _get_code(input_vars, output_vars, mode, type):
	var t_b_c = "top_base_color";
	if input_vars[0]:
		t_b_c = input_vars[0]
		
	var fragcode = """
	vec4 orm = triplanar_texture_argh(top_ORM, side_ORM, uv1_power_normal, uv1_triplanar_pos).rgba;
	{ALBEDO} = triplanar_texture_argh({top_base_color}, side_base_color, uv1_power_normal, uv1_triplanar_pos).rgb; //vec3(1.,0.,0.);
	{NORMAL_MAP} = triplanar_texture_argh(top_normal_map, side_normal_map, uv1_power_normal, uv1_triplanar_pos).rgb;
	{AO} = orm.r * light_affect;
	{ROUGHNESS} = orm.g * roughness;
	{METALLIC} = orm.b * metallic;
	{SPECULAR} = 0.5 - clamp(1.0-orm.r, 0.0, 0.5);
""".format(
	{
		"ALBEDO": output_vars[0],
		"top_base_color": t_b_c,
		"NORMAL_MAP": output_vars[1],
		"AO": output_vars[2],
		"ROUGHNESS": output_vars[3],
		"METALLIC": output_vars[4],
		"SPECULAR": output_vars[5]
		})
	return fragcode
