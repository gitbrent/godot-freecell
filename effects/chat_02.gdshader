shader_type canvas_item;

uniform vec4 line_color : source_color;
uniform float line_thickness : hint_range(0.0, 10.0) = 1.0;
uniform float pulse_speed : hint_range(0.1, 10.0) = 1.0; // Speed of the pulsating effect

void fragment() {
    // Assuming UV is normalized (0.0 to 1.0), no direct need for TEXTURE_SIZE
    float distance_from_center = length(UV - vec2(0.5, 0.5)); // Centered around the middle

    // Calculate a pulsating effect based on time
    float pulse = abs(sin(TIME * pulse_speed));

    // Determining the pulsating effect's range
    float outline = smoothstep(0.45, 0.5 + pulse * 0.05, distance_from_center); // Adjust values as needed

    // Outline effect
    vec4 sprite_color = texture(TEXTURE, UV);
    COLOR = mix(sprite_color, line_color * outline, outline);
}
