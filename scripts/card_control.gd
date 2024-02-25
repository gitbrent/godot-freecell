extends Control

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			get_parent().dragging = true
			get_parent().drag_offset = get_global_mouse_position() - get_parent().global_position
			get_parent().original_position = get_parent().global_position
			get_parent().emit_signal("card_drag_started", get_parent(), get_global_mouse_position())
		else:
			get_parent().dragging = false
			get_parent().emit_signal("card_drag_ended", get_parent())
