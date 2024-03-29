extends Control

signal card_drag_start(card, mouse_position)
signal drag_in_progress(card, mouse_position)
signal card_drag_ended(card)
signal card_double_clicked(card)

var last_click_time = 0
var double_click_threshold = 0.3  # Seconds; adjust as needed

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var current_time = Time.get_ticks_msec() / 1000.0  # Convert milliseconds to seconds
			if current_time - last_click_time <= double_click_threshold:
				emit_signal("card_double_clicked", get_parent())
			else:
				# Not a double-click, treat as a start drag or single click
				emit_signal("card_drag_start", get_parent(), get_global_mouse_position())
			last_click_time = current_time
		else:
			emit_signal("card_drag_ended", get_parent())
			pass
	elif event is InputEventMouseMotion:
		emit_signal("drag_in_progress", get_parent(), event.global_position)
