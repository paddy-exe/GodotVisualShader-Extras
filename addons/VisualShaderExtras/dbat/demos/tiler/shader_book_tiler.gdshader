shader_type spatial;


uniform vec2 u_resolution;
uniform float u_time;

uniform sampler2D frag;

//#define PI 3.14159265358979323846

vec2 rotate2D(vec2 _st, float _angle) {
    _st -= 0.5;
    _st = mat2( vec2(cos(_angle), -sin(_angle)), vec2(sin(_angle), cos(_angle)) ) * _st;
    _st += 0.5;
    return _st;
}



float box(vec2 _st, vec2 _size, float _smoothEdges){
    _size = vec2(0.5)-_size*0.5;
    vec2 aa = vec2(_smoothEdges*0.5);
    vec2 uv = smoothstep(_size,_size+aa,_st);
    uv *= smoothstep(_size,_size+aa,vec2(1.0)-_st);
    return uv.x*uv.y;
}

float circle(in vec2 _st, in float _radius){
    vec2 l = _st-vec2(0.5);
    return 1.-smoothstep(_radius-(_radius*0.01),
                         _radius+(_radius*0.01),
                         dot(l,l)*4.0);
}

vec2 tile(vec2 _st, float _zoom){
    _st *= _zoom;
    return fract(_st);
}

void fragment() {
//	vec2 st = UV.xy/u_resolution;
//    vec3 color = vec3(0.0);
//
//    st *= 3.0;      // Scale up the space by 3
//    st = fract(st); // Wrap around 1.0
//
//    // Now we have 9 spaces that go from 0-1
//
//    color = vec3(st,0.0);
//    //color = vec3(circle(st,0.5));
//
//	ALBEDO = vec4(color,1.0).rgb;

	vec2 voodoo(vec2 st) {
		//
		return _st;
	}
	
    vec2 st = UV.xy/u_resolution.xy;
    vec3 color = vec3(0.0);

    // Divide the space in n
    st = tile(st,8.);

    // Use a matrix to rotate the space 45 degrees
    st = rotate2D(st,PI*0.25);
	//vec4 pic = texture(frag, st); 
	vec3 pic = vec3(box(st, vec2(0.7), 0.01)); 

    // Draw a square
    color = pic.rgb;// vec3(box(st,vec2(0.7),0.01));
    // color = vec3(st,0.0);

    ALBEDO = color;//vec4(color,1.0).rgb;
}
