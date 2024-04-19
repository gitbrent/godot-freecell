extends Node2D

signal start_button_pressed()

@onready var audio_btn_click:AudioStreamPlayer = $AudioBtnClick
@onready var animation_player:AnimationPlayer = $AnimationPlayer

func _ready():
	animation_player.play("spin_card")

func _on_start_button_pressed():
	audio_btn_click.play()
	emit_signal("start_button_pressed")
