shader_type canvas_item;

uniform float speed;
uniform vec3 color1;
uniform vec3 color2;
uniform float zoom = 1.0;


vec2 random2(vec2 st){
    st = vec2(dot(st, vec2(127.1,311.7)),
              dot(st, vec2(269.5,183.3)));
    return -1.0 + 2.0*fract(sin(st)*43758.5453123);
}

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec2 rotated_gradient(vec2 grid_point, float t) {
    float angle = hash(grid_point) * 6.2831853 + t; // 2π + time offset
    return vec2(cos(angle), sin(angle));
}

float perlin(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

	float time = TIME * speed;
    // Four gradient vectors
    vec2 a = rotated_gradient(random2(i), time);
    vec2 b = rotated_gradient(random2(i + vec2(1.0, 0.0)), time);
    vec2 c = rotated_gradient(random2(i + vec2(0.0, 1.0)), time);
    vec2 d = rotated_gradient(random2(i + vec2(1.0, 1.0)), time);
		
    // Vectors from grid points to pixel
    vec2 u = f;

    // Dot product
    float va = dot(a, u);
    float vb = dot(b, u - vec2(1.0, 0.0));
    float vc = dot(c, u - vec2(0.0, 1.0));
    float vd = dot(d, u - vec2(1.0, 1.0));

    // Smooth interpolation
    vec2 fade = u*u*u*(u*(u*6.0 - 15.0) + 10.0);
    float x1 = mix(va, vb, fade.x);
    float x2 = mix(vc, vd, fade.x);
    return mix(x1, x2, fade.y);
}

void fragment() {
    vec2 pos = UV * zoom; // less zoom
    float n = 1.0 - perlin(pos);
	n = smoothstep(0.7, 1.0, n);
	
    vec4 col = vec4(vec3(color1*n), 1.0);
	if(n < 0.5) col += vec4(color1 / 3.0, 1.0);
	COLOR = col;
}
