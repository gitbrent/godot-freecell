extends Control
class_name MainMenu

signal button_pressed_newgame()
signal button_pressed_debug()

func _on_btn_resume_pressed():
	visible = false

func _on_btn_newgame_pressed():
	emit_signal("button_pressed_newgame")

func _on_btn_debug_pressed():
	emit_signal("button_pressed_debug")
