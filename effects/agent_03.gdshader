shader_type canvas_item;

uniform vec4 line_color: source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float line_thickness: hint_range(0.0, 10.0) = 1.0;
uniform float pulse_speed: hint_range(0.1, 10.0) = 1.0;
uniform float start_offset: hint_range(0.0, 20.0) = 5.0; // Start offset in pixels

void fragment() {
    // Convert the start offset from pixels to UV coordinates, considering the texture size including padding
    float offsetUVX = start_offset / (88.0 + 2.0 * start_offset);
    float offsetUVY = start_offset / (128.0 + 2.0 * start_offset);
    vec2 center = vec2(0.5, 0.5); // Center of the UV coordinates
    
    // Adjust the UV coordinates to account for the start offset
    vec2 adjustedUV = (UV - vec2(offsetUVX, offsetUVY)) / (1.0 - 2.0 * vec2(offsetUVX, offsetUVY));
    
    // Calculate distance from the center, adjusted for the starting offset
    float distance = length(adjustedUV - center) * 2.0; // Normalized distance [0, 1] from the center
    
    // Calculate the pulse effect based on time
    float pulse = abs(sin(TIME * pulse_speed));
    
    // Calculate the alpha for the pulse effect, starting from outside the sprite
    float alpha = smoothstep(1.0 + 2.0 * offsetUVX, 1.0 - 2.0 * (line_thickness / 128.0), distance + pulse);

    // Get the original sprite color
    vec4 sprite_color = texture(TEXTURE, UV);
    
    // Mix the pulse color with the sprite color based on the calculated alpha
    vec4 final_color = mix(sprite_color, line_color, alpha * sprite_color.a); // Use sprite's alpha to maintain transparency
    
    COLOR = final_color;
}
