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


## NOTES
## This is way too fragile
## 1. Saving the gd or the nodegraph causes some kind of refresh
## 2. I can't tell when a port is connected or disconnected
## Therefore i can't guarantee that my lib is keeping track of
## functions deployed properly.

## create the node:
#init
	#get_in_count
	#get_in_name
	#GET IN PORT type
	#get_in_name
	#GET IN PORT type
	#get_in_name
	#GET IN PORT type
	#get_out_count
	#get_out_name
	#GET OUT PORT type
	#get name

## saved
#init
#get name
#get_desc
#get_icon
#get_cat
	#get_in_count <-- same as create
	#get_in_name
	#GET IN PORT type
	#get_in_name
	#GET IN PORT type
	#get_in_name
	#GET IN PORT type
	#get_out_count
	#get_out_name
	#GET OUT PORT type
	#get name

## connect it to output
#get global
#get name
#get code

## disconnect output FROM non custom node
# nothing...


##delete (even when plugged in)
# nothing

## disconnection_request <-- does not happen

## duplicate
#init
#init
	#get_in_count
	#get_in_name
	#GET IN PORT type
	#get_in_name
	#GET IN PORT type
	#get_in_name
	#GET IN PORT type
	#get_out_count
	#get_out_name
	#GET OUT PORT type
	#get name
#get global
#get name
#get code

## click on input node that is connected to
## another CUSTOM node
## causes that node to disconnect!
#get name
#get global
#get name
#get code

## plug into another Custom node that is
## not connected to the final output node
# get name

## unplug again ^ same situation
# get name


##Open the scene file
#get_in_count
#get_in_name
#GET IN PORT type
#get_in_name
#GET IN PORT type
#get_in_name
#GET IN PORT type
#get_out_count
#get_out_name
#GET OUT PORT type
#get global
#get name
#get code












@tool
extends VisualShaderNodeCustom
class_name TESTNodeUVRotate

var call_order:String = ""

func _get_name():
	print("get name")
	call_order+="N"
	return "TESTUVRotate"

func _get_version():
	return "1"
	
func _get_category():
	print("get_cat")
	return "VisualShaderExtras/TEST"

func _get_description():
	print("get_desc")
	return LizardShaderLibrary.format_description(self,
	"Rotates UV coordinates around a pivot point.")

func _get_return_icon_type():
	print("get_icon")
	return VisualShaderNode.PORT_TYPE_VECTOR_2D

func _get_output_port_type(port):
	print("GET OUT PORT type")
	return VisualShaderNode.PORT_TYPE_VECTOR_2D
	
func _get_output_port_count():
	print("get_out_count")
	return 1

func _get_output_port_name(port: int) -> String:
	print("get_out_name")
	return "UV"
	
var lib:ShaderFuncRef
func _init() -> void:
	print("init")
	lib = ShaderFuncRef.new()
	set_input_port_default_value(1, Vector2(0., 0.)) #pivot
	set_input_port_default_value(2, 0.0) #rot
	
	connect("disconnection_request",discon) # does fa :(
#	connect("editor_refresh_request",discon)

func discon():
	print("disconnection_request")
	
func _get_input_port_count():
	print("get_in_count")
	return 3

func _get_input_port_name(port):
	print("get_in_name")
	match port:
		0: return "UV"
		1: return "Pivot"
		2: return "Rotation (Radians)"

func _get_input_port_type(port):
	print("GET IN PORT type")
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D #UV
		1: return VisualShaderNode.PORT_TYPE_VECTOR_2D #pivot
		2: return VisualShaderNode.PORT_TYPE_SCALAR #radians


func _get_global_code(mode):
	print("get global")
	if call_order == "N":
		#N then G means disconnect or duplicate
		#So, let's return nothing
		call_order=""
		return ""
	call_order += "G"
	return lib.get_unique_funcs(self,["vec2_rotate"])
	
	#return LizardShaderLibrary.vec2_rotate

func _notification(what): #useless
	print("notif:",what) #you get what == 1 on duplicate of node
	
func _get_code(input_vars, output_vars, mode, type):
	print(self.get_local_scene()) #useful
	print(self.output_ports_live) #true when con to output node
	
	print("get code")
	return ""
	
	var uv = input_vars[0] if input_vars[0] else "UV"
	return """
	vec2 rotated_uv = {uv};
	rotated_uv = vec2_rotate({uv}, {rand_rotation}, {pivot});
	{out_uv} = rotated_uv;
	""".format(
		{
		"uv": uv,
		"pivot": input_vars[1],
		"rand_rotation": input_vars[2],
		"out_uv": output_vars[0] 
		})


	return """
	vec2 rotated_uv = {uv};
	rotated_uv = vec2_rotate({uv}, {rand_rotation}, {pivot});
	{vec2_rotate_here}
	{out_uv} = rotated_uv;
	""".format(
		{
		"uv": uv,
		"pivot": input_vars[1],
		"rand_rotation": input_vars[2],
		"out_uv": output_vars[0] 
		})
		
