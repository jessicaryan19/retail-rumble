shader_type canvas_item;

// === OUTLINE ===
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 1.0;

// === FLASH ===
uniform bool flash_active = false;
uniform vec3 flash_color = vec3(0.835 , 0.294 , 0.0509);
uniform float flash_mix_strength : hint_range(0.0, 1.0) = 1.0;

// === BLINK ===
uniform bool blink_active = false;
uniform vec3 blink_color = vec3(1.0);
uniform float blink_mix_strength : hint_range(0.0, 1.0) = 1.0;
uniform float blink_speed : hint_range(1.0, 50.0) = 20.0;

uniform float opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	vec3 final_color = original_color.rgb;

	// === BLINK (white pulse with sine wave) ===
	if (blink_active) {
		float wave = abs(sin(TIME * blink_speed));
		final_color = mix(final_color, blink_color, blink_mix_strength * wave);
	}

	// === FLASH (instant red override) ===
	if (flash_active) {
		final_color = mix(final_color, flash_color, flash_mix_strength);
	}

	// === OUTLINE ===
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;
	float max_neighbor_alpha = 0.0;

	vec2 offset_n = vec2(0.0, -1.0) * outline_width * pixel_size;
	vec2 offset_ne = vec2(0.707, -0.707) * outline_width * pixel_size;
	vec2 offset_e = vec2(1.0, 0.0) * outline_width * pixel_size;
	vec2 offset_se = vec2(0.707, 0.707) * outline_width * pixel_size;
	vec2 offset_s = vec2(0.0, 1.0) * outline_width * pixel_size;
	vec2 offset_sw = vec2(-0.707, 0.707) * outline_width * pixel_size;
	vec2 offset_w = vec2(-1.0, 0.0) * outline_width * pixel_size;
	vec2 offset_nw = vec2(-0.707, -0.707) * outline_width * pixel_size;

	max_neighbor_alpha = max(max_neighbor_alpha, texture(TEXTURE, UV + offset_n).a);
	max_neighbor_alpha = max(max_neighbor_alpha, texture(TEXTURE, UV + offset_ne).a);
	max_neighbor_alpha = max(max_neighbor_alpha, texture(TEXTURE, UV + offset_e).a);
	max_neighbor_alpha = max(max_neighbor_alpha, texture(TEXTURE, UV + offset_se).a);
	max_neighbor_alpha = max(max_neighbor_alpha, texture(TEXTURE, UV + offset_s).a);
	max_neighbor_alpha = max(max_neighbor_alpha, texture(TEXTURE, UV + offset_sw).a);
	max_neighbor_alpha = max(max_neighbor_alpha, texture(TEXTURE, UV + offset_w).a);
	max_neighbor_alpha = max(max_neighbor_alpha, texture(TEXTURE, UV + offset_nw).a);

	float outline_amount = step(original_color.a, 0.1) * max_neighbor_alpha;

	// === Final blending ===
	vec4 blended_color = vec4(final_color, original_color.a * opacity);
	COLOR = mix(blended_color, outline_color, outline_amount);
}
