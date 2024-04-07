shader_type canvas_item;

// Uniforms allow you to customize the shader behavior in the Godot editor
uniform float border_size: hint_range(1.0, 20.0) = 4.0;
uniform vec4 border_color: source_color = vec4(0.0, 1.0, 0.0, 0.8); // Red color
uniform vec2 TEXTURE_SIZE = vec2(88,128);

void fragment() {
    // Time-based pulsation effect. Adjust '5.0' to change speed.
    float pulsate = abs(sin(TIME * 5.0)) * 10.0;
    float current_border_size = border_size + pulsate;
    
    // Sample the texture in several points around the current fragment
    // to determine if we're on the edge (based on alpha transition)
    float alpha = texture(TEXTURE, UV).a;
    float min_neighbor_alpha = 1.0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offset = vec2(float(x), float(y)) * current_border_size / vec2(SCREEN_PIXEL_SIZE.x * TEXTURE_SIZE.x, SCREEN_PIXEL_SIZE.y * TEXTURE_SIZE.y);
            float neighbor_alpha = texture(TEXTURE, UV + offset).a;
            min_neighbor_alpha = min(min_neighbor_alpha, neighbor_alpha);
        }
    }

    // If there's an alpha transition, render the border
    if (alpha < 0.1 && min_neighbor_alpha > 0.1) {
        COLOR = border_color;
    } else {
        // Inside the sprite; just show the sprite itself
        COLOR = texture(TEXTURE, UV);
    }
}
