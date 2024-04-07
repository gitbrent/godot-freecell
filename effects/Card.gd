extends Node2D

var pulse_start_time = 0.0
var is_pulsing = false
var pulse_duration = 5.0 # Duration of the pulse in seconds

func _ready():
	#var brent = texture.get_rect().size
	# Assuming your Sprite node has a material that is a ShaderMaterial
	#var texture_size = Vector2(texture.get_width(), texture.get_height())
	#material.set_shader_parameter("texture_size", texture_size)
	# Initialize other shader parameters as needed
	#material.set_shader_parameter("time_passed", 0.0)
	pass

func _process(delta):
	if is_pulsing:
		pulse_start_time += delta
		material.set_shader_parameter("delta_time", pulse_start_time)
		
		# Stop pulsing after the pulse_duration
		if pulse_start_time >= pulse_duration:
			is_pulsing = false
			pulse_start_time = 0 # Optionally reset for the next pulse

func trigger_pulse():
	pulse_start_time = 0.0 # Reset start time
	is_pulsing = true

func _on_texture_button_pressed():
	trigger_pulse()
