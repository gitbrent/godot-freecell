extends Node

@onready var start_scene:Node2D = $StartScene
@onready var game_scene:Node2D = $GameScene

# Called when the node enters the scene tree for the first time.
func _ready():
	start_scene.connect("start_button_pressed", on_start_button_pressed)

func on_start_button_pressed():
	start_scene.visible = false
	game_scene.visible = true
