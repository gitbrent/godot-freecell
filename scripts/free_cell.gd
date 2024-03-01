extends Control
class_name FreeCell

# Load the style resources
var free_cell_hover_style = preload("res://styles/free_cell_hover.tres")
var free_cell_normal_style = preload("res://styles/free_cell_normal.tres")

# Signals
signal card_hover_free_start(free_cell : FreeCell)
signal card_hover_free_ended(free_cell : FreeCell)

#@onready var color_rect = $ColorRect
@onready var panel:Panel = $Panel

# Vars
var card_in_cell : Card = null
var vertical_offset : int = 1
var horizontal_offset : int = 1

func add_card(card: Card):
	if card is Card:
		add_child(card) # Add the card to this node
		var card_position = Vector2(horizontal_offset, vertical_offset)
		card.position = card_position
		card_in_cell = card
		#print("[FreeCell] added card with position: ", card.position)
	else:
		print("[tableau] attempted to add a non-Card node to the pile.")

func remove_card(card: Card):
	if card == card_in_cell:
		remove_child(card)
		card_in_cell = null

func remove_all():
	if card_in_cell:
		remove_card(card_in_cell)

func _on_area_2d_area_entered(area):
	if not card_in_cell:
		emit_signal("card_hover_free_start", self)
	
	# WIP:
	#print($Panel.theme)
	# Ensure the Panel has a Theme assigned; if not, create and assign one dynamically
	if $Panel.theme == null:
		$Panel.theme = Theme.new()

	#$Panel.add_theme_stylebox_override("hover", free_cell_hover_style)
	$Panel.theme.set_stylebox("panel", "Panel", free_cell_hover_style)

	#$Panel.remove_theme_stylebox_override("hover")
	#print($Panel.theme)
	#$Panel.stylebox = free_cell_hover_style
	#print($ColorRect.modulate)
	#$ColorRect.modulate = Color(1, 0, 0, 1)  # Change color to red for example
	

func _on_area_2d_area_exited(_area):
	emit_signal("card_hover_free_ended", self)
	
	# WIP:
	$Panel.theme.set_stylebox("panel", "Panel", free_cell_normal_style)
