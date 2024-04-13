shader_type canvas_item;

uniform vec4 inner_color : source_color = vec4(0.0, 0.8, 0.0, 1.0);
uniform vec4 border_color_start : source_color = vec4(0.5, 1.0, 0.5, 1.0);
uniform vec4 border_color_end : source_color = vec4(0.0, 0.5, 0.0, 1.0);
uniform float pulse_time : hint_range(1.0, 10.0) = 3.0;
uniform float border_thickness : hint_range(1.0, 50.0) = 20.0;

void fragment() {
    float norm_border_thickness = 20.0; //border_thickness / min(textureSize(TEXTURE, 0).x, textureSize(TEXTURE, 0).y);
    float dist_to_left = UV.x;
    float dist_to_right = 1.0 - UV.x;
    float dist_to_top = UV.y;
    float dist_to_bottom = 1.0 - UV.y;
    float dist_to_nearest_edge = min(min(dist_to_left, dist_to_right), min(dist_to_top, dist_to_bottom));
    bool in_border = dist_to_nearest_edge < norm_border_thickness;

    float pulse = (sin(TIME / pulse_time * 2.0 * 3.14159265) + 1.0) / 2.0;
    vec4 border_color = mix(border_color_start, border_color_end, pulse);

    COLOR = in_border ? border_color : inner_color;
}
