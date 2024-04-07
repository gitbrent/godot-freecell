shader_type canvas_item;

uniform vec2 texture_size = vec2(88.0, 128.0); // Your card size
uniform vec4 line_color: source_color = vec4(0.0, 0.7, 0.0, 1.0); // Green color for the border
uniform float duration: hint_range(0.5, 10.0) = 2.0; // Duration of the fade-in effect
uniform float border_start_width: hint_range(1.0, 20.0) = 5.0; // Start width of the border in pixels
uniform float delta_time: hint_range(0.0, 100.0) = 0.0; // Time passed since the start of the effect

// Convert border width from pixels to normalized UV coordinates based on the smaller dimension of the texture size
float border_width_normalized(vec2 textureSize, float borderWidth) {
    return borderWidth / min(textureSize.x, textureSize.y);
}

void fragment() {
    float borderWidth = border_start_width - (border_start_width * clamp(delta_time / duration, 0.0, 1.0));
    float normalizedBorderWidth = border_width_normalized(texture_size, borderWidth);

    // Calculate distance to the nearest edge in normalized coordinates
    float distanceToEdgeX = min(UV.x, 1.0 - UV.x) * texture_size.x;
    float distanceToEdgeY = min(UV.y, 1.0 - UV.y) * texture_size.y;
    float distanceToEdge = min(distanceToEdgeX, distanceToEdgeY);

    // Map distance to the range where the border effect should be applied
    float edgeFactor = smoothstep(0.0, border_width_normalized(texture_size, border_start_width), distanceToEdge / min(texture_size.x, texture_size.y));

    // Use edgeFactor to mix between the card texture color and the border color
    vec4 texColor = texture(TEXTURE, UV);
    vec4 finalColor = mix(line_color, texColor, edgeFactor);

    // If distance to edge is within the current border width, apply the border color; otherwise, use the texture color
    if (distanceToEdge / min(texture_size.x, texture_size.y) < normalizedBorderWidth) {
        COLOR = finalColor;
    } else {
        COLOR = texColor;
    }
}
