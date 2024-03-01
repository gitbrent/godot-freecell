extends Control
class_name FoundationCell

# Load the style resources
var free_cell_hover_style = preload("res://styles/free_cell_hover.tres")
var free_cell_normal_style = preload("res://styles/free_cell_normal.tres")

# Signals
signal card_hover_fnda_start(free_cell : FreeCell)
signal card_hover_fnda_ended(free_cell : FreeCell)

#@onready var color_rect = $ColorRect
@onready var panel:Panel = $Panel

# Vars
var card_in_cell : Card = null
var vertical_offset : int = 1
var horizontal_offset : int = 1

func _ready():
	# Create a theme for StyleBox
	if $Panel.theme == null:
		$Panel.theme = Theme.new()

func add_card(card: Card):
	if card is Card:
		add_child(card) # Add the card to this node
		var card_position = Vector2(horizontal_offset, vertical_offset)
		card.position = card_position
		card_in_cell = card
		print("[Foundation-Cell] added card with position: ", card.position)
	else:
		print("[ERR] attempted to add a non-Card node to the pile.")

func remove_card(card: Card):
	if card == card_in_cell:
		remove_child(card)
		card_in_cell = null

func remove_all():
	if card_in_cell:
		remove_card(card_in_cell)

func _on_area_2d_area_entered(area):
	# Emit signal if a card can go here
	if not card_in_cell:
		emit_signal("card_hover_fnda_start", self)
		
	# Apply hover style
	$Panel.theme.set_stylebox("panel", "Panel", free_cell_hover_style)

func _on_area_2d_area_exited(_area):
	emit_signal("card_hover_fnda_ended", self)
	
	# Reset style
	$Panel.theme.set_stylebox("panel", "Panel", free_cell_normal_style)
