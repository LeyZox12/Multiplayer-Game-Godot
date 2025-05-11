shader_type canvas_item;

uniform float pixelization;
uniform sampler2D screen_texture: hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 pos = UV;
	
	//pos = floor(pos/pixelization)*pixelization;
	vec4 c = textureLod(screen_texture, pos,0.0);
	COLOR = c;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
