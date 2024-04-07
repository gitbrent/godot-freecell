shader_type canvas_item;

uniform vec4 pulse_color: source_color = vec4(0.0, 0.7, 0.0, 1.0); // Pulse color, feel free to adjust
uniform float pulse_speed: hint_range(0.1, 20.0) = 51.0; // Speed of the pulse effect
uniform float pulse_strength: hint_range(0.0, 2.0) = 0.25; // Strength of the pulse's visibility

void fragment() {
    // Correct aspect ratio based on your sprite's dimensions
    vec2 aspect_corrected_uv = UV;
    aspect_corrected_uv.x *= 88.0/128.0; // Correcting for an 88x128 sprite

    // Centering the pulse effect
    vec2 center = vec2(0.5, 0.5 * 128.0/88.0); // Adjust center for the sprite's aspect ratio
    float distance_from_center = length((aspect_corrected_uv - center) * vec2(88.0/128.0, 1.0)); // Distance of current fragment from center

    // Calculate pulse effect based on distance, with outward movement
    float pulse = sin(TIME * pulse_speed + distance_from_center * pulse_strength) * 0.5 + 0.5;

    // Determine alpha based on pulse for the glow effect
    float alpha = smoothstep(0.5, 0.0, pulse); // Adjust these values to change the fade effect

    // Apply the pulse effect on top of the existing sprite color
    vec4 base_color = texture(TEXTURE, UV);
    COLOR = mix(base_color, pulse_color, alpha * (1.0 - base_color.a));
}
