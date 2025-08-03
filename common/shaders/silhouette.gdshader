// silhouette_shader.gd
shader_type canvas_item;

// Original uniforms
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform vec4 silhouette_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform float color_tolerance : hint_range(0.0, 0.1) = 0.01;

// Effect uniforms
uniform bool blink_active = false;
uniform bool flash_active = false;
uniform float blink_speed = 20.0;

void fragment() {
	vec4 sprite_color = texture(TEXTURE, UV);

	if(sprite_color.a <= 0.01){
		discard;
	}

	vec4 screen_color = texture(screen_texture, SCREEN_UV);

	bool colors_match = all(lessThan(abs(sprite_color - screen_color), vec4(color_tolerance)));

	if(colors_match) {
		// This part is for when the main sprite is covering the silhouette area.
		// We can leave it as-is, but a more robust way is to just discard.
		discard;
	} else {
		// This is the part that draws the silhouette. We will modify it.
		float final_alpha = silhouette_color.a * sprite_color.a; // Start with the normal alpha

		if (flash_active) {
			// When flashing, the silhouette should be completely transparent.
			final_alpha = 0.0;
		} else if (blink_active) {
			// This is the only line that needs to change!
			// We subtract the result of step() from 1.0 to invert the wave.
			float blink_wave = 1.0 - step(0.0, abs(sin(TIME * blink_speed)));

			final_alpha = mix(final_alpha, 0.0, blink_wave);
		}

		COLOR = vec4(silhouette_color.rgb, final_alpha);
	}
}