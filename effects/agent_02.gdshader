shader_type canvas_item;

uniform vec4 line_color: source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float line_thickness : hint_range(0.0, 10.0) = 1.0;
uniform float pulse_time: hint_range(0.1, 10.0) = 1.0;
uniform float delta_time : hint_range(0.1, 10.0) = 1.0;

// Adjust these values to match your sprite size and the desired offset.
const vec2 sprite_size = vec2(88.0, 128.0);
const float offset = 5.0; // The distance outside the sprite you want the pulse to start.

void fragment() {
    // Adjust the UV coordinates to include the offset.
    vec2 adjusted_uv = (UV - 0.5) * (sprite_size / (sprite_size + vec2(offset * 2.0))) + 0.5;
    
    // Calculate the distance from the center to create the pulse effect.
    float distance_from_center = length(adjusted_uv - vec2(0.5, 0.5));
    
    // Normalize the distance based on the sprite size and offset.
    float normalized_distance = distance_from_center * (sprite_size.x + offset * 2.0) / sprite_size.x;
    
    // Pulse calculation.
    float pulse = sin(delta_time * pulse_time * 2.0 * PI + normalized_distance * 10.0);
    pulse = clamp(pulse, 0.0, 1.0);
    
    // Apply the effect based on the pulse value.
    vec4 color = texture(TEXTURE, UV);
    vec4 final_color = mix(color, line_color * vec4(1.0, 1.0, 1.0, pulse), pulse);
    
    // Ensure that we respect the sprite's original alpha.
    COLOR = vec4(final_color.rgb, color.a);
}
