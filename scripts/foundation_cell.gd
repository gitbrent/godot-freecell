extends Control
class_name FoundationCell

var free_cell_hover_style = preload("res://styles/free_cell_hover.tres")
var free_cell_normal_style = preload("res://styles/free_cell_normal.tres")

signal card_hover_fnda_start(fnda_cell : FoundationCell)
signal card_hover_fnda_ended(fnda_cell : FoundationCell)

@onready var panel_hover : Panel = $PanelHover
@onready var panel_normal : Panel = $PanelNormal
@onready var border_animation = $BorderAnimation

var cards : Array = []
var card_added : Card

# =====================================

func _ready():
	highlight(false)

func is_empty():
	return cards.size() == 0

func get_top_card():
	if cards.size() > 0:
		return cards[cards.size() - 1]
	else:
		return null

func get_card_count():
	return cards.size()

func add_card(card: Card):
	if card is Card:
		add_child(card)
		card.position = Enums.CARD_POSITION
		cards.append(card)
		card_added = card
		#print("[Foundation-Cell] added card: ", Enums.human_readable_card(card))
	else:
		print("[ERR] attempted to add a non-Card node to the pile.")

func remove_card(card: Card):
	remove_child(card)
	cards.erase(card)

func remove_all_cards():
	while cards.size() > 0:
		remove_card(cards[0])

func _on_area_2d_area_entered(_area):
	if not card_added:
		emit_signal("card_hover_fnda_start", self)
	else:
		card_added = null

func _on_area_2d_area_exited(_area):
	emit_signal("card_hover_fnda_ended", self)

func highlight(isVisible:bool):
	panel_hover.visible = isVisible
	border_animation.visible = isVisible
	panel_normal.visible = !isVisible
