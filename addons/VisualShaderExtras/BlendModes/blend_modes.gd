@tool
class_name VisualShaderNodeBlendModes
extends VisualShaderNodeCustom

func _init():
	var op = get_option_index(0)
	set_input_port_default_value(2, 0.5)

func _get_name():
	return "BlendModes"

func _get_category():
	return "VisualShaderExtras/BlendModes"

func _get_description():
	return ""

func _get_return_icon_type():
	return PORT_TYPE_VECTOR_3D

func _get_property_count():
	return 1

func _get_property_name(index):
	return ""

func _get_property_options(index: int):
	return [
	"Additive",
	"AddSub",
	"Burn",
	"Darken",
	"Difference",
	"Dissolve",
	"Dodge",
	"Exclusion",
	"GammaDark",
	"GammaIllumination",
	"GammaLight",
	"HardLight",
	"HardMix",
	"Lighten",
	"LinearBurn",
	"LinearLight",
	"Luminosity",
	"Multiply",
	"Normal",
	"Overlay",
	"PinLight",
	"Screen",
	"SoftLight",
	"VividLight"
]

func _get_default_input_port(type):
	return 0

func _get_input_port_count():
	var op: int = get_option_index(0)
	match op:
		# Dissolve
		5:
			return 4
		# default
		_:
			return 3

func _get_input_port_name(port):
	var op: int = get_option_index(0)
	match op:
		# Dissolve
		5:
			match port:
				0:
					return "Top layer"
				1:
					return "Bottom layer"
				2:
					return "Opacity"
				3:
					return "Noise Seed"
		# default
		_:
			match port:
				0:
					return "Top layer"
				1:
					return "Bottom layer"
				2:
					return "Opacity"


func _get_input_port_type(port):
	var op: int = get_option_index(0)
	match op:
		# Dissolve
		5:
			match port:
				0:
					return VisualShaderNode.PORT_TYPE_VECTOR_3D
				1:
					return VisualShaderNode.PORT_TYPE_VECTOR_3D
				2:
					return VisualShaderNode.PORT_TYPE_SCALAR
				3:
					return VisualShaderNode.PORT_TYPE_VECTOR_3D
		# default
		_:
			match port:
				0:
					return VisualShaderNode.PORT_TYPE_VECTOR_3D
				1:
					return VisualShaderNode.PORT_TYPE_VECTOR_3D
				2:
					return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "Output"

func _get_output_port_type(port):
	return PORT_TYPE_VECTOR_3D

func _get_global_code(mode):
	var op: int = get_option_index(0)
	
	match op:
		#region Additive
		0:
			return """
				vec3 blend_additive(vec3 c1, vec3 c2, float oppacity) {
					return c2 + c1 * oppacity;
				}
			"""
		#endregion
		#region AddSub 
		1:
			return """
				vec3 blend_addsub(vec3 c1, vec3 c2, float oppacity) {
					return c2 + (c1 - .5) * 2.0 * oppacity;
				}
			"""
		#endregion
		#region Burn
		2:
			return """
				float blend_burn_f(float c1, float c2) {
					return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
				}
				
				vec3 blend_burn(vec3 c1, vec3 c2, float opacity) {
					return opacity*vec3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region Darken
		3:
			return """
				vec3 blend_darken(vec3 c1, vec3 c2, float opacity) {
					return opacity*min(c1, c2) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region Difference
		4:
			return """
				vec3 blend_difference(vec3 c1, vec3 c2, float opacity) {
					return opacity*clamp(c2-c1, vec3(0.0), vec3(1.0)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region Dissolve
		5:
			return """
				// 3D Noise with friendly permission by Inigo Quilez
				vec3 hash_noise_range( vec3 p ) {
					p *= mat3(vec3(127.1, 311.7, -53.7), vec3(269.5, 183.3, 77.1), vec3(-301.7, 27.3, 215.3));
					return 2.0 * fract(fract(p)*4375.55) -1.;
				}

				float random_range(vec3 seed, float min, float max) {
					return mix(min, max, hash_noise_range(seed).x);
				}
				
				vec3 blend_dissolve(vec3 seed, vec3 c1, vec3 c2, float opacity) {
					if (random_range(vec3(seed), 0.0, 1.0) < opacity) {
						return c1;
					} else {
						return c2;
					}
				}
			"""
		#endregion
		#region Dodge
		6:
			return """
				float blend_dodge_f(float c1, float c2) {
					return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
				}

				vec3 blend_dodge(vec3 c1, vec3 c2, float opacity) {
					return opacity*vec3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region Exclusion
		7:
			return """
				float blend_exclusion_f(float c1, float c2) {
					return c1 + c2 - 2.0 * c1 * c2;
				}
				
				vec3 blend_exclusion(vec3 c1, vec3 c2, float opacity) {
					return opacity*vec3(blend_exclusion_f(c1.x, c2.x), blend_exclusion_f(c1.y, c2.y), blend_exclusion_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region GammaDark
		8:
			return """
				float blend_gamma_dark_f(float c1, float c2)
				{
					return pow(c2, (1.0 / c1));
				}
				
				vec3 blend_gamma_dark(vec3 c1, vec3 c2, float opacity)
				{
					return opacity*vec3(blend_gamma_dark_f(c1.x, c2.x), blend_gamma_dark_f(c1.y, c2.y), blend_gamma_dark_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region GammaIllumination
		9:
			return """
				float blend_gamma_illumination_f(float c1, float c2) 
				{
					return (1.0 - pow(c2, (1.0 / c1)));
				}
				
				vec3 blend_gamma_illumination(vec3 c1, vec3 c2, float opacity)
				{
					return opacity*vec3(blend_gamma_illumination_f(c1.x, c2.x), blend_gamma_illumination_f(c1.y, c2.y), blend_gamma_illumination_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region GammaLight
		10:
			return """
				float blend_gamma_light_f(float c1, float c2) 
				{
					return pow(c2, c1);
				}
				
				vec3 blend_gamma_light(vec3 c1, vec3 c2, float opacity)
				{
					return opacity*vec3(blend_gamma_light_f(c1.x, c2.x), blend_gamma_light_f(c1.y, c2.y), blend_gamma_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region HardLight
		11:
			return """
				float blend_overlay_f(float c1, float c2) {
					return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
				}
				
				vec3 blend_overlay(vec3 c1, vec3 c2, float opacity) {
					return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
				
				vec3 blend_hard_light(vec3 c1, vec3 c2, float opacity) {
					return opacity*0.5*(c1*c2+blend_overlay(c1, c2, 1.0)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region HardMix
		12:
			return """
				float blend_hard_mix_f(float c1, float c2) {
					return floor(c1 + c2);
				}

				vec3 blend_hard_mix(vec3 c1, vec3 c2, float opacity) {
					return opacity*vec3(blend_hard_mix_f(c1.x, c2.x), blend_hard_mix_f(c1.y, c2.y), blend_hard_mix_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region Lighten
		13:
			return """
				vec3 blend_lighten(vec3 c1, vec3 c2, float opacity) {
					return opacity*max(c1, c2) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region LinearBurn
		14:
			return """
				float blend_linear_burn_f(float c1, float c2) {
					return 1.0- ((1.0 - c1) + (1.0 - c2));
				}
				
				vec3 blend_linear_burn(vec3 c1, vec3 c2, float opacity) {
					return opacity*vec3(blend_linear_burn_f(c1.x, c2.x), blend_linear_burn_f(c1.y, c2.y), blend_linear_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region LinearLight
		15:
			return """
				float blend_linear_light_f(float c1, float c2) {
					return (c1 + 2.0 * c2) - 1.0;
				}
				
				vec3 blend_linear_light(vec3 c1, vec3 c2, float opacity) {
					return opacity*vec3(blend_linear_light_f(c1.x, c2.x), blend_linear_light_f(c1.y, c2.y), blend_linear_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region Luminosity
		16:
			return """
				float blend_luminosity_f( float c1, float c2 )
				{
					float dLum = dot(vec3(c2), vec3(0.3, 0.59, 0.11));
					float sLum = dot(vec3(c1), vec3(0.3, 0.59, 0.11));
					float lum = sLum - dLum;
					float c = c2 + lum;
					if(c < 0.0) return sLum + ((c - sLum) * sLum) / (sLum - c);
					else if(c > 1.0) return sLum + ((c - sLum) * (1.0 - sLum)) / (c - sLum);
					else return c;
				}
				
				vec3 blend_luminosity(vec3 c1, vec3 c2, float opacity)
				{
					return opacity*vec3(blend_luminosity_f(c1.x, c2.x), blend_luminosity_f(c1.y, c2.y), blend_luminosity_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region Multiply
		17:
			return """
				vec3 blend_multiply(vec3 c1, vec3 c2, float opacity) {
					return opacity*c1*c2 + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region Normal
		18:
			return """
				vec3 blend_normal(vec3 c1, vec3 c2, float opacity) {
					return opacity*c1 + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region Overlay
		19:
			return """
				float blend_overlay_f(float c1, float c2) {
					return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
				}

				vec3 blend_overlay(vec3 c1, vec3 c2, float opacity) {
					return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region PinLight
		20:
			return """
				float blend_pin_light_f( float c1, float c2) {
					return (2.0 * c1 - 1.0 > c2) ? 2.0 * c1 - 1.0 : ((c1 < 0.5 * c2) ? 2.0 * c1 : c2);
				}
				
				vec3 blend_pin_light(vec3 c1, vec3 c2, float opacity) {
					return opacity*vec3(blend_pin_light_f(c1.x, c2.x), blend_pin_light_f(c1.y, c2.y), blend_pin_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region Screen
		21:
			return """
				vec3 blend_screen(vec3 c1, vec3 c2, float opacity) {
					return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region SoftLight
		22:
			return """
				float blend_soft_light_f(float c1, float c2) {
					return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
				}

				vec3 blend_soft_light(vec3 c1, vec3 c2, float opacity) {
					return opacity*vec3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
			"""
		#endregion
		#region VividLight
		23:
			return """
				float blend_vivid_light_f(float c1, float c2) {
					return (c1 < 0.5) ? 1.0 - (1.0 - c2) / (2.0 * c1) : c2 / (2.0 * (1.0 - c1));
				}
				
				vec3 blend_vivid_light(vec3 c1, vec3 c2, float opacity) {
					return opacity*vec3(blend_vivid_light_f(c1.x, c2.x), blend_vivid_light_f(c1.y, c2.y), blend_vivid_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
				}
			"""
		#endregion


func _get_code(input_vars, output_vars, mode, type):
	var op = get_option_index(0)
	match op:
		0:
			return "%s.rgb = blend_additive(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		1:
			return "%s.rgb = blend_addsub(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		2:
			return "%s.rgb = blend_burn(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		3:
			return "%s.rgb = blend_darken(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		4:
			return "%s.rgb = blend_difference(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		5:
			return "%s.rgb = blend_dissolve(%s.rgb, %s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[3], input_vars[0], input_vars[1], input_vars[2]]
		6:
			return "%s.rgb = blend_dodge(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		7:
			return "%s.rgb = blend_exclusion(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		8:
			return "%s.rgb = blend_gamma_dark(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		9:
			return "%s.rgb = blend_gamma_illumination(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		10:
			return "%s.rgb = blend_gamma_light(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		11:
			return "%s.rgb = blend_hard_light(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		12:
			return "%s.rgb = blend_hard_mix(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		13:
			return "%s.rgb = blend_lighten(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		14:
			return "%s.rgb = blend_linear_burn(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		15:
			return "%s.rgb = blend_linear_light(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		16:
			return "%s.rgb = blend_luminosity(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		17:
			return "%s.rgb = blend_multiply(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		18:
			return "%s.rgb = blend_normal(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		19:
			return "%s.rgb = blend_overlay(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		20:
			return "%s.rgb = blend_pin_light(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		21:
			return "%s.rgb = blend_screen(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		22:
			return "%s.rgb = blend_soft_light(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
		23:
			return "%s.rgb = blend_vivid_light(%s.rgb, %s.rgb, %s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2]]
