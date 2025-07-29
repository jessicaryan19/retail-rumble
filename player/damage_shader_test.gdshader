shader_type canvas_item;
uniform float opacity;
uniform float r;
uniform float g;
uniform float b;
uniform float mix_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 texture_color = texture(TEXTURE, UV);
	if(texture_color.a != 0.0)
		COLOR = vec4(mix(texture_color.rgb, vec3(r,g,b), mix_color), opacity);
}

void light() {

	float cNdotL = max(1.0, dot(NORMAL, LIGHT_DIRECTION));
	LIGHT = vec4(LIGHT_COLOR.rgb * LIGHT_ENERGY * cNdotL, LIGHT_COLOR.a);
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
}
