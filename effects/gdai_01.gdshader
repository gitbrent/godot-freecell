shader_type canvas_item;

// Uniforms for controlling the pulsating effect
uniform float pulse_speed : hint_range(0.1, 10.0) = 3.0;
uniform vec4 pulse_color : source_color = vec4(0.0, 0.8, 0.0, 0.8); // Red color for the pulse
uniform float max_pulse_extent : hint_range(0.0, 20.0) = 10.0; // Maximum extent of the pulse beyond the sprite edge in pixels

void fragment() {
    // Calculate the sprite's UV boundaries within the texture
    float left_bound = 3.0 / 108.0; // Left boundary of the sprite in UV space
    float right_bound = 105.0 / 108.0; // Right boundary
    float top_bound = 3.0 / 148.0; // Top boundary in UV space
    float bottom_bound = 145.0 / 148.0; // Bottom boundary

    // Determine if the current pixel is inside the sprite's area
    bool is_inside_sprite = UV.x > left_bound && UV.x < right_bound && UV.y > top_bound && UV.y < bottom_bound;

    // Calculate normalized distance to the nearest edge within the sprite
    float dist_to_edge = min(min(UV.x - left_bound, right_bound - UV.x), min(UV.y - top_bound, bottom_bound - UV.y));
    dist_to_edge /= max(right_bound - left_bound, bottom_bound - top_bound); // Normalize by the largest dimension

    // Calculate the pulse offset based on the elapsed time
    float pulse_offset = abs(sin(TIME * pulse_speed)) * (max_pulse_extent / 108.0); // Normalize pulse extent to UV space

    // Check if the pixel is within the pulse range starting from the sprite edge
    bool in_pulse_range = dist_to_edge <= pulse_offset;

    // Sample the original texture color
    vec4 original_color = texture(TEXTURE, UV);

    // Apply the pulse effect
    if (is_inside_sprite || in_pulse_range) {
        float pulse_strength = smoothstep(pulse_offset, pulse_offset - (5.0 / 108.0), dist_to_edge); // Smooth fade effect
        COLOR = mix(original_color, pulse_color, pulse_strength);
    } else {
        COLOR = original_color;
    }
}
