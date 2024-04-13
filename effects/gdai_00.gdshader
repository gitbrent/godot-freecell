shader_type canvas_item;

// Define uniforms for the color transition
uniform vec4 light_green : source_color = vec4(0.0, 0.78, 0.0, 1.0); // Light green
uniform vec4 dark_green : source_color = vec4(0.0, 0.5, 0.0, 1.0); // Dark green
uniform float pulse_time : hint_range(1.0, 10.0) = 1.5; // Time in seconds for one full pulse

void fragment() {
    // Calculate the oscillation factor using a sinusoidal wave
    float t = mod(TIME, pulse_time) / pulse_time; // Normalized time for one pulse cycle
    float pulse = (sin(t * 2.0 * 3.14159) + 1.0) * 0.5; // Oscillate between 0 and 1

    // Interpolate between light green and dark green based on the pulse value
    vec4 color = mix(dark_green, light_green, pulse);

    // Apply the calculated color to the fragment
    COLOR = color;
}
