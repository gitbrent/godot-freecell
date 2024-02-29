extends Control

# Declare signals for the drag start, drag in progress, and drag end
signal card_drag_start(card, mouse_position)
signal drag_in_progress(card, mouse_position)
signal card_drag_ended(card)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			emit_signal("card_drag_start", get_parent(), get_global_mouse_position())
		else:
			emit_signal("card_drag_ended", get_parent())
	elif event is InputEventMouseMotion:
		emit_signal("drag_in_progress", get_parent(), event.global_position)
