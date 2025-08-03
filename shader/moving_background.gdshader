shader_type canvas_item;

uniform float h_speed = 0;
uniform float v_speed = 0.4;

uniform float alpha = 1;
void vertex() {

	UV.x += TIME * h_speed;
	UV.y += TIME * v_speed;
}

void fragment() {
	COLOR.a = alpha;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
