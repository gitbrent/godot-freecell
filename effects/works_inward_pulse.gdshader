shader_type canvas_item;

uniform vec4 line_color: source_color = vec4(0.0, 0.7, 0.0, 1.0);
uniform float line_thickness : hint_range(0.0, 10.0) = 1.0;
uniform float pulse_time: hint_range(0.1, 10.0) = 1.0;
uniform float delta_time : hint_range(0.1, 10.0) = 1.0;

float smoothstep(float edge0, float edge1, float x) {
  float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
  return t * t * (3.0 - 2.0 * t);
}

float pulse_outward(float time, float duration, float max_distance, vec2 my_uv) {
  float progress = clamp(time / duration, 0.0, 1.0);  // Progress from 0 to 1 in duration
  float distance = progress * max_distance;  // Distance increases with progress
  // Using UV directly. Ensure the mesh/texture being used has proper UVs.
  float outline = smoothstep(0.0, distance, length(my_uv - vec2(0.5, 0.5)));  // Centered around (0.5, 0.5) for a texture
  return outline;
}

void fragment() {
  vec2 pixel_size = 1.0 / vec2(88.0, 128.0);  // Compute pixel size from texture size
  vec2 size = pixel_size * line_thickness;
  float max_distance = 5.0;  // Adjust for max pulse distance in pixels
  float outline = pulse_outward(delta_time, pulse_time, max_distance, UV);

  vec4 color = texture(TEXTURE, UV);

  // Apply the pulse effect based on the original color's alpha.
  // This makes the effect more prominent in opaque areas while leaving transparent areas mostly unaffected.
  vec4 pulse_color = mix(color, line_color, outline);
  COLOR = vec4(pulse_color.rgb, color.a); // Keep original alpha
}
