shader_type canvas_item;

uniform float opacity = 1.0;

uniform bool blink_active = false;
uniform bool flash_active = false;

uniform float blink_speed = 20.0;
uniform float flash_mix_strength = 1.0;
uniform float blink_mix_strength = 1.0;

uniform vec3 blink_color = vec3(1.0, 1.0, 1.0); // white
uniform vec3 flash_color = vec3(0.835, 0.294, 0.051); // red

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	// Always define a base color
	vec3 final_color = tex_color.rgb;

	if (blink_active) {
		float blink_wave = abs(sin(TIME * blink_speed));
		final_color = mix(final_color, blink_color, blink_mix_strength * blink_wave);
	}

	if (flash_active) {
		final_color = mix(final_color, flash_color, flash_mix_strength);
	}

	COLOR = vec4(final_color, tex_color.a * opacity);
}
