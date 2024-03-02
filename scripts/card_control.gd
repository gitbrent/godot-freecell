extends Control

signal card_drag_start(card, mouse_position)
signal drag_in_progress(card, mouse_position)
signal card_drag_ended(card)
signal request_move_to_freecell(card)

var last_click_time = 0
var double_click_threshold = 0.3  # Seconds; adjust as needed

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var current_time = Time.get_ticks_msec() / 1000.0  # Convert milliseconds to seconds
			if current_time - last_click_time <= double_click_threshold:
				_on_card_double_clicked()
			else:
				# Not a double-click, treat as a start drag or single click
				emit_signal("card_drag_start", get_parent(), get_global_mouse_position())
			last_click_time = current_time
		else:
			# Mouse button released, end drag
			emit_signal("card_drag_ended", get_parent())
	elif event is InputEventMouseMotion:
		emit_signal("drag_in_progress", get_parent(), event.global_position)

func _on_card_double_clicked():
	print("[control] Card double-clicked!")
	# Now call the function to attempt to move the card to a FreeCell
	emit_signal("request_move_to_freecell", get_parent())
