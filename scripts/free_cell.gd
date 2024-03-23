extends Control
class_name FreeCell

var free_cell_hover_style = preload("res://styles/free_cell_hover.tres")
var free_cell_normal_style = preload("res://styles/free_cell_normal.tres")

signal card_hover_free_start(free_cell : FreeCell)
signal card_hover_free_ended(free_cell : FreeCell)

@onready var panel:Panel = $Panel

var card_in_cell : Card = null

func _ready():
	# Create a theme for StyleBox
	if $Panel.theme == null:
		$Panel.theme = Theme.new()

func is_empty():
	return not card_in_cell

func get_curr_card():
	#print("[free_cell] card_in_cell: ", card_in_cell)
	return card_in_cell

func add_card(card: Card):
	if card is Card:
		#print("[FreeCell] added card: {" + Enums.human_readable_card(card_in_cell) + "} with position: ", card.position)
		add_child(card)
		card.position = Vector2(0, 0)
		card_in_cell = card
	else:
		print("[tableau] attempted to add a non-Card node to the pile.")

func remove_card(card: Card):
	if card == card_in_cell:
		remove_child(card)
		card_in_cell = null

func remove_all():
	if card_in_cell:
		remove_card(card_in_cell)

func _on_area_2d_area_entered(_area):
	# Emit signal if a card can go here
	if not card_in_cell:
		emit_signal("card_hover_free_start", self)
	
	# Apply hover style
	$Panel.theme.set_stylebox("panel", "Panel", free_cell_hover_style)

func _on_area_2d_area_exited(_area):
	emit_signal("card_hover_free_ended", self)
	
	# Reset style
	$Panel.theme.set_stylebox("panel", "Panel", free_cell_normal_style)
