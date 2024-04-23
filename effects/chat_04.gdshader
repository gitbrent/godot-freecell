shader_type canvas_item;

uniform vec4 pulse_color: source_color = vec4(1.0, 1.0, 1.0, 1.0); // Pulse color
uniform float pulse_speed: hint_range(0.1, 20.0) = 5.0; // Speed of the pulse effect
uniform float pulse_strength: hint_range(0.0, 2.0) = 0.5; // Strength of the pulse's visibility
uniform float max_outline_distance: hint_range(0.0, 5.0) = 1.0; // Max distance for the outline to expand

void fragment() {
    // Aspect ratio correction
    vec2 aspect_corrected_uv = UV;
    aspect_corrected_uv.x *= 88.0/128.0; // Adjusting for an 88x128 sprite

    // Centering the pulse effect
    vec2 center = vec2(0.5, 0.5 * 128.0/88.0); // Adjust center for the sprite's aspect ratio
    float distance_from_center = length((aspect_corrected_uv - center) * vec2(88.0/128.0, 1.0)); // Distance of current fragment from center

    // Calculate pulse effect with a limit on the maximum expansion distance
    float pulse = sin(TIME * pulse_speed + distance_from_center * pulse_strength) * 0.5 + 0.5;
    float alpha = smoothstep(0.5, 0.0, pulse);

    // Limiting the expansion of the pulse effect
    float max_distance_effect = smoothstep(max_outline_distance, 0.0, distance_from_center - 0.5); // Adjust the "- 0.5" to control the starting point

    // Apply the pulse effect on top of the existing sprite color, considering the max distance
    vec4 base_color = texture(TEXTURE, UV);
    COLOR = mix(base_color, vec4(pulse_color.rgb, pulse_color.a * max_distance_effect), alpha * (1.0 - base_color.a));
}
