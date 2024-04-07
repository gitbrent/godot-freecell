shader_type canvas_item;

uniform vec4 line_color: source_color = vec4(0.0, 0.7, 0.0, 0.8); // Green color for the pulse
uniform float line_thickness: hint_range(0.0, 10.0) = 1.0; // Thickness of the line
uniform float delta_time: hint_range(0.1, 10.0) = 1.0; // Time since the last frame
uniform float pulse_time: hint_range(0.1, 10.0) = 2.0; // Total duration of the pulse
uniform float fade_time: hint_range(0.1, 10.0) = 1.0; // Time for the fade effect
uniform float start_radius: hint_range(0.0, 1.0) = 0.5; // Start radius for the pulse, as a fraction of texture size

// Function for the fade effect
float fade(float time, float duration) {
    return 1.0 - clamp(time / duration, 0.0, 1.0);
}

void fragment() {
    vec2 centered_uv = UV - vec2(0.5, 0.5); // Center the UV coordinates
    float distance_from_center = length(centered_uv) * 2.0; // Calculate distance from the center

    // Calculate the fade based on delta_time and fade_time
    float fade_effect = fade(delta_time, fade_time);
    
    // Determine if the current pixel is within the starting area
    float in_start_area = step(distance_from_center, start_radius);

    // Adjust outline based on whether we're inside the start area
    float outline = mix(fade_effect, 1.0, in_start_area);

    vec4 color = texture(TEXTURE, UV);
    vec4 final_color = mix(color, line_color, outline * (1.0 - color.a));
    COLOR = final_color;
}
