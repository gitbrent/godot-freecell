shader_type canvas_item;

uniform vec4 line_color: source_color = vec4(0.0, 0.7, 0.0, 1.0);
uniform float line_thickness : hint_range(0.0, 10.0) = 1.0;
uniform float delta_time = 0.0;
uniform float pulse_time : hint_range(0.1, 10.0) = 3.0;

float smoothstep(float edge0, float edge1, float value) {
  // Implement smoothstep function for smooth transition
  return clamp((value - edge0) / (edge1 - edge0), 0.0, 1.0);
}

float pulse_outward(float time, float duration, float max_distance, vec2 env_uv) {
  float prog = clamp(time / duration, 0.0, 1.0);  // Progress from 0 to 1 in duration
  float dist = prog * max_distance;  // Distance increases with progress
  float outline = smoothstep(0.0, dist, length(env_uv));  // Outline based on distance from center
  return outline;
}

void fragment() {
  vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
  float max_distance = 10.0;  // Adjust for max pulse distance in pixels
  float outline = pulse_outward(delta_time, pulse_time, max_distance, UV);

  vec4 color = texture(TEXTURE, UV);
  vec4 final_color = mix(color, line_color, outline * (1.0 - color.a));
  COLOR = final_color;
}
