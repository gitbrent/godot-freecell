extends Control
class_name WinnerScene

signal button_pressed_newgame()

@onready var animation_player:AnimationPlayer = $BlueBox/AnimationPlayer
@onready var gpu_particles_2d:GPUParticles2D = $GPUParticles2D

func _ready():
	animation_player.play("scale_star")
	gpu_particles_2d.emitting = true

func _on_btn_newgame_pressed():
	emit_signal("button_pressed_newgame")
	visible = false
