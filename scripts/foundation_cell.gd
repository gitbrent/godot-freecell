extends Control
class_name FoundationCell

# Load the style resources
var free_cell_hover_style = preload("res://styles/free_cell_hover.tres")
var free_cell_normal_style = preload("res://styles/free_cell_normal.tres")

# Signals
signal card_hover_fnda_start(fnda_cell : FoundationCell)
signal card_hover_fnda_ended(fnda_cell : FoundationCell)

@onready var panel:Panel = $Panel

# Vars
var cards : Array = []

func _ready():
	# Create a theme for StyleBox
	if $Panel.theme == null:
		$Panel.theme = Theme.new()

func is_empty():
	return cards.size() == 0

func get_top_card():
	if cards.size() > 0:
		return cards[cards.size() - 1]
	else:
		return null

func add_card(card: Card):
	if card is Card:
		add_child(card) # Add the card to this node
		var card_position = Vector2(0, 0)
		card.position = card_position
		cards.append(card)
		print("[Foundation-Cell] added card with position: ", card.position)
	else:
		print("[ERR] attempted to add a non-Card node to the pile.")

func remove_all():
	cards.clear()

func _on_area_2d_area_entered(area):
	# Emit signal
	emit_signal("card_hover_fnda_start", self)
	# Apply hover style
	$Panel.theme.set_stylebox("panel", "Panel", free_cell_hover_style)

func _on_area_2d_area_exited(_area):
	# Emit signal
	emit_signal("card_hover_fnda_ended", self)
	# Reset style
	$Panel.theme.set_stylebox("panel", "Panel", free_cell_normal_style)

func highlight(enable:bool):
	# TODO:
	print("[highlight]: ", enable)
