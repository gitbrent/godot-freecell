shader_type canvas_item;

uniform vec4 line_color: source_color = vec4(0.0, 0.7, 0.0, 1.0);
uniform float line_thickness : hint_range(0.0, 10.0) = 1.0;
uniform float delta_time : hint_range(0.0, 5.0) = 0.0;
uniform float pulse_time : hint_range(0.5, 10.0) = 2.0;
uniform float fade_time : hint_range(0.5, 10.0) = 2.0;

float pulse(float time, float speed, float strength) {
 return sin(time * speed) * strength + 0.5;
}

float fade(float time, float duration) {
 return 1.0 - clamp(time / duration, 0.0, 1.0);
}

void fragment() {
 vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
 //float outline = pulse(delta_time, pulse_time, 1.5); // Adjust for pulse
 float outline = fade(delta_time, fade_time); // Use this for fade
 outline = clamp(outline, 0.0, 1.0);

 vec4 color = texture(TEXTURE, UV);
 vec4 final_color = mix(color, line_color, outline * (1.0 - color.a));
 COLOR = final_color;
}