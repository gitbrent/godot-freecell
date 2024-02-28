extends Control
class_name FreeCell

# Signals
signal card_hover_free_start()
signal card_hover_free_ended()

# Vars
var card_in_cell : Card = null
var vertical_offset = 1
var horizontal_offset = 1

func add_card(card: Card):
	if card is Card:
		add_child(card) # Add the card to this node
		var card_position = Vector2(horizontal_offset, vertical_offset)
		card.position = card_position
		card_in_cell = card
		print("[FreeCell] added card with position: ", card.position)
	else:
		print("[tableau] attempted to add a non-Card node to the pile.")

func remove_card(card: Card):
	remove_child(card)
	card_in_cell = null

func _on_area_2d_area_entered(_area):
	if not card_in_cell:
		emit_signal("card_hover_free_start")

func _on_area_2d_area_exited(_area):
	emit_signal("card_hover_free_ended")
